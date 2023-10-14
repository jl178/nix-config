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
                indicator = "#2e9ef4";
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
