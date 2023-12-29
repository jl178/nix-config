{ config, pkgs, inputs, ... }:

let
  modifier = "Mod1";
in
{
  config = {
    home-manager.users.jered = { pkgs, ... }: {
      xsession.windowManager.i3 = {
          enable = true;
          package = pkgs.i3-gaps;
          extraConfig = ''
            # needed for dual screens
            # exec xrandr --output eDP-1-1 --auto --left-of HDMI-0 &
            exec xrandr --output eDP-1-1 --auto --noprimary --left-of HDMI-0
            exec xrandr --output HDMI-0 --primary
            # Fix background image after boot
            exec ${pkgs.feh}/bin/feh --bg-fill ~/.background-image
            set $ws1 "1"
            set $ws2 "2"
            set $ws3 "3"
            set $ws4 "4"
            set $ws5 "5"
            set $ws6 "6"
            set $ws7 "7"
            set $ws8 "8"
            set $ws9 "9"
            set $ws10 "10"

            bindcode Mod1+10 workspace number $ws1
            bindcode Mod1+11 workspace number $ws2
            bindcode Mod1+12 workspace number $ws3
            bindcode Mod1+13 workspace number $ws4
            bindcode Mod1+14 workspace number $ws5
            bindcode Mod1+15 workspace number $ws6
            bindcode Mod1+16 workspace number $ws7
            bindcode Mod1+17 workspace number $ws8
            bindcode Mod1+18 workspace number $ws9
            bindcode Mod1+19 workspace number $ws10

            bindcode Mod1+Shift+10 move container to workspace number $ws1
            bindcode Mod1+Shift+11 move container to workspace number $ws2
            bindcode Mod1+Shift+12 move container to workspace number $ws3
            bindcode Mod1+Shift+13 move container to workspace number $ws4
            bindcode Mod1+Shift+14 move container to workspace number $ws5
            bindcode Mod1+Shift+15 move container to workspace number $ws6
            bindcode Mod1+Shift+16 move container to workspace number $ws7
            bindcode Mod1+Shift+17 move container to workspace number $ws8
            bindcode Mod1+Shift+18 move container to workspace number $ws9
            bindcode Mod1+Shift+19 move container to workspace number $ws10
          '';
          config = {
            inherit modifier;


            bars = [ ];

            window = {
              border = 3;
              hideEdgeBorders = "both";
              titlebar = false;
            };
            colors = {
              focused = {
                border = "#3c3836";
                background = "#285577";
                text = "#FFFFFF";
                indicator = "#3c3836";
                childBorder = "#3c3836";
                };
            };

            gaps = {
              inner = 10;
              outer = 5;
            };

            keybindings = {
              # Alacritty terminal
              "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";

              # Rofi
              # "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";

              # Screenshot
              # "${modifier}+shift+s" = "exec ${pkgs.flameshot}/bin/flameshot gui -c";
              # "${modifier}+shift+a" = "exec ${pkgs.flameshot}/bin/flameshot gui";

              # Movement
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+h" = "focus left";
              "${modifier}+l" = "focus right";

              # Workspaces
              # "${modifier}+space" = "workspace ${workspace.terminal}";
              # "${modifier}+m" = "workspace ${workspace.code}";
              # "${modifier}+comma" = "workspace ${workspace.browser}";
              # "${modifier}+period" = "workspace ${workspace.bitwarden}";
              # "${modifier}+slash" = "workspace ${workspace.spotify}";
              # "${modifier}+u" = "workspace ${workspace.discord}";
              # "${modifier}+i" = "workspace ${workspace.signal}";
              # "${modifier}+o" = "workspace ${workspace.extra-1}";
              # "${modifier}+p" = "workspace ${workspace.extra-2}";

              # Misc
              "${modifier}+shift+q" = "kill";
              "${modifier}+f" = "fullscreen toggle";
              "${modifier}+z" = "split h";
              "${modifier}+x" = "split v";
              "${modifier}+r" = "mode resize";
            };

            modes.resize = {
              "h" = "resize grow width 10 px or 10 ppt";
              "j" = "resize shrink height 10 px or 10 ppt";
              "k" = "resize grow height 10 px or 10 ppt";
              "l" = "resize shrink width 10 px or 10 ppt";
              "Escape" = "mode default";
            };

            startup = [
              {
                command = "${pkgs.xmousepasteblock}/bin/xmousepasteblock";
                always = true;
                notification = false;
              }
              {
                command = "systemctl --user restart polybar.service";
                always = true;
                notification = false;
              }
              {
                command = "${pkgs.xbanish}/bin/xbanish";
                always = true;
                notification = false;
              }
              {
                command = "${pkgs.kitty}/bin/kitty";
                always = false;
                notification = false;
              }
            ];
          };
      };
      # home.file.".background.webp".source = ./background.webp;
    };
  };
}
