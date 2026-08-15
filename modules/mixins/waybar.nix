{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.jered = { pkgs, ... }:
      let
        # Proton VPN status for the bar.
        #
        # Ask which interface real internet traffic would actually leave by,
        # and check whether that is a Proton tunnel. `ip route get` is the
        # only correct way to ask: WireGuard does not replace the default
        # route in the main table, it installs an fwmark rule pointing at a
        # separate, randomly-numbered table. So while connected, `ip route
        # show default` still reports eno0 and looks disconnected, while
        # `ip route get 1.1.1.1` correctly reports proton0. Do not "simplify"
        # this back to reading the default route.
        #
        # The interface name is matched as a family (pvpn*, proton*, wg*)
        # because Proton has changed it across releases. Verified against this
        # host that docker0, the br-* bridges and veth* never match, and that
        # Proton's ipv6leakintrf0 killswitch dummy is not mistaken for the
        # tunnel.
        vpnStatus = pkgs.writeShellScript "waybar-vpn-status" ''
          dev=$(${pkgs.iproute2}/bin/ip route get 1.1.1.1 2>/dev/null \
            | ${pkgs.gawk}/bin/awk '{for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
          case "$dev" in
            pvpn*|proton*|wg*)
              printf '{"text":" VPN","class":"connected","tooltip":"Proton VPN connected - traffic exits via %s"}\n' "$dev"
              ;;
            *)
              printf '{"text":" VPN","class":"disconnected","tooltip":"Proton VPN NOT connected - traffic exits via %s"}\n' "''${dev:-unknown}"
              ;;
          esac
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

          #custom-vpn.connected {
              color: #b8bb26; /* green */
              border-radius: 10px 0px 0px 10px;
              border-left: 0px;
              border-right: 0px;
          }

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
            # Launch only if it is not already running. Re-running the
            # binary does NOT raise the existing window -- it forks a second
            # instance -- so an unconditional launch here quietly accumulates
            # duplicate clients every time the module is clicked.
            #
            # There is no click-to-raise available: the app's tray item
            # implements no Activate method (left-click is a no-op) and
            # org.gtk.Application.Activate on the live instance does nothing
            # either. To bring the window back once it is minimised to tray,
            # RIGHT-click the tray icon and use its menu.
            on-click = "${pkgs.procps}/bin/pgrep -f protonvpn-app > /dev/null || ${pkgs.protonvpn-gui}/bin/protonvpn-app";
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
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            format-disconnected = "Disconnected ⚠";
            format-ethernet =
              "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
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
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" "" "" ];
          };
        }];
      };
    };
  };
}
