{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font";
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
    padding: 5px;
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
#custom-weather,
#window,
#clock,
#battery,
#pulseaudio,
#network,
#cpu,
#memory,
#bluetooth,
#temperature,
#workspaces,
#tray,
#backlight {
    background: #3c3836; /* bg2 */
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
    background: #3c3836; /* bg2 */
    border-radius: 10px;
    margin-left: 10px;
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

#clock {
    color: #d79921;     
    border-radius: 10px;
}

#network {
    color: #d79921; /* yellow */
    border-radius: 10px 0px 0px 10px;
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
    border-radius: 0px 10px 10px 0px;
    border-right: 0px;
    margin-left: 0px;
}
    '';
    settings = [{
      height = 50;
      layer = "top";
      position = "top";
      tray = { spacing = 10; };
      modules-center = [ "hyprland/window" ];
      modules-left = [ "clock" ];
      modules-right = [
        "network"
        "bluetooth"
        "temperature"
        "battery"
        "pulseaudio"
        "cpu"
        "memory"
      ] # ++ (if config.hostId == "system76" then [ "battery" ] else [ ])
      ++ [
        "tray"
      ];
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
        format = "{: %I:%M %p   %a, %b %e}";
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
        format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
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
}
