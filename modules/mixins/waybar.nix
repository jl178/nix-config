{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.jered = { pkgs, ... }:
      let
        # Proton VPN state for the bar. Three states, not two.
        #
        # Which interface would traffic leave by? `ip route get` is the only
        # correct way to ask: WireGuard installs an fwmark rule pointing at a
        # separate, randomly numbered table rather than replacing the default
        # route, so `ip route show default` still names eno0 while connected.
        # Do not "simplify" this back to reading the default route.
        #
        # Then, if the tunnel is up, how old is the handshake? A WireGuard
        # peer can go away with the interface still up, routes still
        # installed and everything looking fine, while traffic silently
        # blackholes. The handshake timestamp is the only thing that catches
        # it. Keepalive is 25s, so anything past ~180s is genuinely wrong
        # rather than merely idle.
        vpnStatus = pkgs.writeShellScript "waybar-vpn-status" ''
          dev=$(${pkgs.iproute2}/bin/ip route get 1.1.1.1 2>/dev/null \
            | ${pkgs.gawk}/bin/awk '{for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
          case "$dev" in
            proton*|pvpn*|wg*) ;;
            *)
              printf '{"text":" VPN","class":"disconnected","tooltip":"Proton VPN DOWN - traffic exits via %s. Click to connect."}\n' "''${dev:-unknown}"
              exit 0
              ;;
          esac
          hs=$(${pkgs.sudo}/bin/sudo -n ${pkgs.wireguard-tools}/bin/wg show proton0 latest-handshakes 2>/dev/null \
            | ${pkgs.gawk}/bin/awk '{print $2; exit}')
          now=$(${pkgs.coreutils}/bin/date +%s)
          if [ -n "$hs" ] && [ "$hs" -gt 0 ] 2>/dev/null; then
            age=$((now - hs))
          else
            age=-1
          fi
          if [ "$age" -ge 0 ] && [ "$age" -le 180 ]; then
            printf '{"text":" VPN","class":"connected","tooltip":"Proton VPN up via %s\rhandshake %ss ago\rClick to disconnect."}\n' "$dev" "$age"
          elif [ "$age" -gt 180 ]; then
            printf '{"text":" VPN","class":"stale","tooltip":"Tunnel is up but the last handshake was %ss ago - the peer may be gone and traffic may be blackholing.\rClick to reconnect."}\n' "$age"
          else
            printf '{"text":" VPN","class":"connected","tooltip":"Proton VPN up via %s (handshake age unavailable)\rClick to disconnect."}\n' "$dev"
          fi
        '';

        # Click handler: stop the tunnel if it is up, start it if it is not.
        # systemctl needs privilege, granted narrowly for this single unit by
        # the polkit rule in hosts/oryp11. Signals waybar afterwards so both
        # the VPN state and the public IP refresh at once rather than waiting
        # out their poll intervals.
        vpnToggle = pkgs.writeShellScript "waybar-vpn-toggle" ''
          if ${pkgs.systemd}/bin/systemctl is-active --quiet wg-quick-proton0; then
            ${pkgs.systemd}/bin/systemctl stop wg-quick-proton0
          else
            ${pkgs.systemd}/bin/systemctl start wg-quick-proton0
          fi
          sleep 2
          ${pkgs.procps}/bin/pkill -SIGRTMIN+9 waybar || true
        '';

        # Round-trip time to the internet. On Starlink behind a VPN this is
        # the number that actually predicts whether a call or a stream will
        # feel bad, and it separates "the link is struggling" from "something
        # else is wrong". Fixed width so the bar does not jitter.
        latency = pkgs.writeShellScript "waybar-latency" ''
          rtt=$(${pkgs.iputils}/bin/ping -c 2 -W 2 -q 1.1.1.1 2>/dev/null \
            | ${pkgs.gawk}/bin/awk -F'/' '/rtt|round-trip/ {printf "%.0f", $5; exit}')
          if [ -z "$rtt" ]; then
            printf '{"text":"  --","class":"down","tooltip":"No reply from 1.1.1.1"}\n'
          elif [ "$rtt" -ge 150 ]; then
            printf '{"text":" %3sms","class":"bad","tooltip":"Round-trip to 1.1.1.1: %sms"}\n' "$rtt" "$rtt"
          elif [ "$rtt" -ge 80 ]; then
            printf '{"text":" %3sms","class":"warn","tooltip":"Round-trip to 1.1.1.1: %sms"}\n' "$rtt" "$rtt"
          else
            printf '{"text":" %3sms","class":"good","tooltip":"Round-trip to 1.1.1.1: %sms"}\n' "$rtt" "$rtt"
          fi
        '';

        # Public IP and who owns it.
        #
        # This is deliberately an INDEPENDENT check on the VPN indicator. That
        # one reasons about routing; this one asks the internet what address it
        # actually sees and which company owns it. If the two ever disagree,
        # trust this one -- it is measuring the thing that matters rather than
        # inferring it.
        #
        # P = Proton, S = Starlink/SpaceX, ? = anything else, which is itself
        # worth noticing. Polled every 5 minutes to stay well inside ipinfo's
        # free tier, and refreshed on demand by the toggle via SIGRTMIN+9.
        publicIp = pkgs.writeShellScript "waybar-public-ip" ''
          resp=$(${pkgs.curl}/bin/curl -4 -s --max-time 6 https://ipinfo.io/json 2>/dev/null)
          ip=$(printf '%s' "$resp" | ${pkgs.jq}/bin/jq -r '.ip // empty' 2>/dev/null)
          org=$(printf '%s' "$resp" | ${pkgs.jq}/bin/jq -r '.org // empty' 2>/dev/null)
          if [ -z "$ip" ]; then
            printf '{"text":" no-ip","class":"unknown","tooltip":"Could not reach ipinfo.io to determine the public IP"}\n'
            exit 0
          fi
          # Owner drives the COLOUR only -- green for Proton, red for the
          # bare ISP -- rather than a letter in the text, which just looked
          # like a stray character. The org name goes in the tooltip.
          #
          # Match the ASN first: it is stable, the human-readable name is
          # not. Starlink reports itself as "AS14593 Space Exploration
          # Technologies Corporation", containing neither "Starlink" nor
          # "SpaceX", so name matching alone falls through to unknown.
          case "$org" in
            AS62371*|*[Pp]roton*)                       cls=proton ;;
            AS14593*|*Space\ Exploration*|*[Ss]tarlink*) cls=isp ;;
            *)                                          cls=unknown ;;
          esac
          printf '{"text":"%s %s","class":"%s","tooltip":"%s\r%s"}\n' \
            "" "$ip" "$cls" "$ip" "''${org:-unknown owner}"
        '';
      in {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        style = ''
          * {
              border: none;
              border-radius: 0;
              font-family: "JetBrainsMono Nerd Font Bold";
              font-weight: bold;
              font-size: 13px;
              min-height: 0;
          }

          window#waybar {
              background: rgba(29, 32, 33, 0);
              color: #d4be98; /* bg1 */
          }

          tooltip {
              background: #3c3836; /* bg2 */
              border-radius: 10px;
              border-width: 2px;
              border-style: solid;
              border-color: #282828; /* bg0 */
          }

          #workspaces button {
              padding: 2px;
              color: #504945; /* bg3 */
              margin-right: 5px;
          }

          #workspaces button.active {
              color: #d4be98; /* bg1 */
          }

          #workspaces button.focused {
              color: #d4be98; /* bg1 */
              background: #cc241d; /* red */
              border-radius: 10px;
          }

          #workspaces button.urgent {
              color: #282828; /* bg0 */
              background: #98971a; /* yellow */
              border-radius: 10px;
          }

          #workspaces button:hover {
              background: #282828; /* bg0 */
              color: #d4be98; /* bg1 */
              border-radius: 10px;
          }

          /* Repeating modules */

          #custom-power_profile,
          #custom-vpn,
          #custom-publicip,
          #custom-latency,
          #custom-weather,
          #window,
          #clock,
          #battery,
          #pulseaudio,
          #network,
          #cpu,
          #memory,
          #custom-nix,
          #bluetooth,
          #temperature,
          #workspaces,
          #tray,
          #backlight {
              background: rgba(60,56,54, .7); /* bg2 */
              opacity: 0.8;
              padding: 0px 10px;
              margin: 3px 0px;
              margin-top: 10px;
              border: 1px solid #282828; /* bg0 */
          }

          #temperature {
              border-radius: 10px 0px 0px 10px;
          }

          #temperature.critical {
              color: #cc241d; /* red */
          }

          #backlight {
              border-radius: 10px 0px 0px 10px;
          }

          #tray {
              border-radius: 10px;
              margin-right: 10px;
          }

          #workspaces {
              background: rgba(60,56,54, .7); /* bg2 */
              border-radius: 10px;
              margin-left: 5px;
              padding-right: 0px;
              padding-left: 5px;
          }

          #custom-power_profile {
              color: #98971a; /* yellow */
              border-left: 0px;
              border-right: 0px;
          }

          #window {
              border-radius: 10px;
              margin-left: 60px;
              margin-right: 60px;
          }

          #custom-nix {
              font-family: "JetBrainsMono Nerd Font Bold";
              font-size: 25px;
              color: #83a598; /* yellow */
              border-radius: 10px 10px 10px 10px;
          }

          #clock {
              color: #d79921;
              border-radius: 10px 10px 10px 10px;
              margin-right: 10px;
              margin-left: 10px;
          }

          /* Public IP owner. Independent of the VPN indicator on purpose:
             green only when the internet says Proton owns the address we
             are coming from. If this and the padlock ever disagree, this
             one is measuring rather than inferring. */
          #custom-publicip.proton {
              color: #b8bb26; /* green */
              border-radius: 0px;
              border-left: 0px;
              border-right: 0px;
          }

          #custom-publicip.isp {
              color: #fb4934; /* red */
              border-radius: 0px;
              border-left: 0px;
              border-right: 0px;
          }

          #custom-publicip.unknown {
              color: #d79921; /* yellow */
              border-radius: 0px;
              border-left: 0px;
              border-right: 0px;
          }

          #custom-vpn.connected {
              color: #b8bb26; /* green */
              border-radius: 10px 0px 0px 10px;
              border-left: 0px;
              border-right: 0px;
          }

          #custom-vpn.stale {
              color: #d79921; /* yellow - up but the handshake has gone stale */
              border-radius: 10px 0px 0px 10px;
              border-left: 0px;
              border-right: 0px;
          }

          /* Fixed minimum widths so the bar stops expanding and contracting.
             Right-aligning the text was not enough on its own: these values
             change length constantly -- "1.2 kb/s" vs "10.6 Mb/s", a two- vs
             three-digit ms, a short vs long IP -- and every change shoved
             every module to their right. A min-width pins the box so only
             the text inside it moves. */
          #network { min-width: 190px; }
          #custom-latency { min-width: 78px; }
          #custom-publicip { min-width: 148px; }
          #temperature { min-width: 76px; }
          #cpu { min-width: 62px; }
          #memory { min-width: 62px; }

          #custom-latency.good { color: #b8bb26; border-radius: 0px; }
          #custom-latency.warn { color: #d79921; border-radius: 0px; }
          #custom-latency.bad  { color: #fb4934; border-radius: 0px; }
          #custom-latency.down { color: #fb4934; border-radius: 0px; }

          #custom-vpn.disconnected {
              color: #fb4934; /* red */
              border-radius: 10px 0px 0px 10px;
              border-left: 0px;
              border-right: 0px;
          }

          /* Square on the left so it butts cleanly against custom/vpn.
             This used to be the first module in modules-right, which is why
             it carried the rounded left edge; custom/vpn now owns that
             position, and leaving both rounded left put a notch between
             them. */
          #network {
              color: #d79921; /* yellow */
              border-radius: 0px;
              border-left: 0px;
              border-right: 0px;
          }

          #cpu {
              color: #d79921; /* yellow */
              border-left: 0px;
              border-right: 0px;
          }

          #memory {
              color: #d79921; /* yellow */
              border-radius: 0px 10px 10px 0px;
              margin-right: 10px;

          }

          #bluetooth {
              color: #83a598; /* green */
              border-radius: 0px 10px 10px 0px;
              margin-right: 10px;
          }

          #pulseaudio {
              color: #83a598; /* green */
              border-left: 0px;
              border-right: 0px;
          }

          #pulseaudio.microphone {
              color: #d3869b; /* pink */
              border-left: 0px;
              border-right: 0px;
              border-radius: 0px 10px 10px 0px;
              margin-right: 10px;
          }

          #battery {
              color: #8ec07c; /* green */
              border-radius: 0 10px 10px 0;
              margin-right: 10px;
              border-left: 0px;
          }

          #custom-weather {
              border-radius: 10px 10px 10px 10px;
              border-right: 0px;
              margin-left: 10px;
          }
        '';
        settings = [{
          height = 50;
          layer = "top";
          position = "top";
          tray = { spacing = 10; };
          modules-center = [ "hyprland/window" ];
          modules-left =
            [ "custom/nix" "clock" "hyprland/workspaces" "custom/weather" ];
          modules-right = [
            "custom/vpn"
            "custom/publicip"
            "custom/latency"
            "network"
            "bluetooth"
            "temperature"
            "battery"
            "pulseaudio"
            "cpu"
            "memory"
          ] # ++ (if config.hostId == "system76" then [ "battery" ] else [ ])
            ++ [ "tray" ];
          "hyprland/workspaces" = {
            format = "";
            format-alt = "";
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          battery = {
            format = "{capacity}% {icon}";
            format-alt = "{time} {icon}";
            format-charging = "{capacity}% ";
            format-icons = [ "" "" "" "" "" ];
            format-plugged = "{capacity}% ";
            states = {
              critical = 15;
              warning = 30;
            };
          };
          "custom/nix" = {
            format = "󱄅";
            tooltip-format = "NixOS";
            on-click = "wezterm";
          };

          "custom/vpn" = {
            exec = "${vpnStatus}";
            return-type = "json";
            interval = 5;
            on-click = "${vpnToggle}";
            # Right-click opens the Proton app, for picking a server other
            # than the one this tunnel is pinned to.
            on-click-right = "${pkgs.procps}/bin/pgrep -f protonvpn-app > /dev/null || ${pkgs.protonvpn-gui}/bin/protonvpn-app";
          };

          "custom/latency" = {
            exec = "${latency}";
            return-type = "json";
            interval = 10;
            signal = 9;
          };

          "custom/publicip" = {
            exec = "${publicIp}";
            return-type = "json";
            interval = 300;
            signal = 9;
            on-click = "${publicIp}";
          };

          "custom/weather" = {
            format = "{}";
            exec = "curl -s wttr.in/?format=1";
            interval = 600;
          };
          bluetooth = {
            format = " {status}";
            format-disabled = ""; # an empty format will hide the module
            format-connected = " {num_connections}";
            tooltip-format = "{device_alias}";
            tooltip-format-connected = " {device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}";
            on-click = "blueman-applet";
          };
          clock = {
            format = " {:%H:%M %p | %a, %b %d}";
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };
          memory = { format = "{}% "; };
          network = {
            interval = 1;
            format-alt = "{ifname}";
            format-disconnected = "Disconnected ⚠";
            # No {ifname}: on a wired link it is always eno0 and never changes,
            # which invites the question "why does it say eno0 when the VPN is
            # up?". It is not wrong - proton0 is a virtual interface layered on
            # top of eno0, and the NIC really is carrying the (encrypted)
            # bytes; measured at 5403 KB on eno0 versus 5248 KB inside the
            # tunnel for the same 5 MB transfer. It just tells you nothing.
            # Tunnel state is custom/vpn's job and the exit address is
            # custom/publicip's. This module is here for throughput.
            # Right-aligned to a fixed width. Without this the bar visibly
            # resizes every second as the value moves between e.g. "1.2 kb/s"
            # and "10.6 Mb/s", dragging every module to its right along with it.
            format-ethernet = "↑{bandwidthUpBits:>9} ↓{bandwidthDownBits:>9}";
            format-linked = "{ifname} (No IP) ";
            format-wifi = "{essid} ({signalStrength}%) ";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon}  {format_source}";
            format-bluetooth-muted = " {icon}  {format_source}";
            format-icons = {
              car = "";
              default = [ "" "" "" ];
              handsfree = "";
              headphones = "";
              headset = "";
              phone = "";
              portable = "";
            };
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            on-click = "pavucontrol";
          };
          "sway/mode" = { format = ''<span style="italic">{}</span>''; };
          temperature = {
            # 80C, i.e. 176F. critical-threshold is always Celsius no matter
            # what the format string displays.
            critical-threshold = 80;
            format = "{temperatureF}°F {icon}";
            # Font Awesome thermometers, five levels. The previous set used
            # U+F769 and U+F76B, which JetBrainsMono Nerd Font does not
            # contain, so only the middle icon ever rendered and the module
            # showed tofu at low and high temperatures. Every codepoint below
            # was checked against the installed font with fc-list.
            format-icons = [ "" "" "" "" "" ];
          };
        }];
      };
    };
  };
}
