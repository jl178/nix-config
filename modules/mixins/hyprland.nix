{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.jered = { pkgs, ... }: {
      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;

        extraConfig = ''
          # monitor=,preferred,auto,1
          # monitor=eDP-1, 1920x1200, auto, 1
          # monitor=HDMI-A-1,preferred,0x0,1
          # monitor=eDP-1,1920x1200,auto,1
          # monitor=HDMI-A-1,preferred,auto,1
          monitor=HDMI-A-1,preferred,auto,1
          monitor=eDP-1,disable,if,HDMI-A-1

            workspace=1
            workspace=2
            workspace=3
            workspace=4
            workspace=5
            workspace=6
            workspace=7
            workspace=8
            workspace=9
            workspace=10
          exec = brightnessctl set 7

          #TODO: Cannot get background working with NixOS natively.
          exec = swaybg -m fill -i ~/.background-image
          cursor {
            no_hardware_cursors = true
          }
          input {
              kb_layout = us
              kb_variant =
              kb_model =
              kb_options =
              kb_rules =

              follow_mouse = 1

              touchpad {
                  natural_scroll = no
              }

              sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
          }

          general {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              gaps_in = 5
              gaps_out = 20
              border_size = 2
              #col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
              col.active_border = rgba(a9b665ee) rgba(d8a657ee) 45deg
              col.inactive_border = rgba(595959aa)
              #col.active_border=rgb(cdd6f4)
              #col.inactive_border = rgba(595959aa)

              layout = dwindle
          }

          misc {
              disable_hyprland_logo = yes
          }

          decoration {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              rounding = 10
              # blur = yes
              # blur_size = 7
              # blur_passes = 3
              # blur_new_optimizations = on
              blurls = lockscreen

              #drop_shadow = yes
              #shadow_range = 4
              #shadow_render_power = 3
              #col.shadow = rgba(1a1a1aee)
          }

          animations {
              enabled = yes

              # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

              bezier = myBezier, 0.05, 0.9, 0.1, 1.05

              animation = windows, 1, 7, myBezier
              animation = windowsOut, 1, 7, default, popin 80%
              animation = border, 1, 10, default
              animation = fade, 1, 7, default
              animation = workspaces, 1, 6, default
          }

          dwindle {
              # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
              pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = yes # you probably want this
          }

          gestures {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              workspace_swipe = off
          }

          windowrulev2 = opacity 0.8 0.8,class:^(kitty)$
          windowrulev2 = opacity 0.8 0.8,class:^(thunar)$

          $mainMod = ALT

          bind = $mainMod, RETURN, exec, kitty #open the terminal
          bind = $mainMod, Q, exec, wezterm #open the backup terminal
          bind = $mainMod SHIFT, Q, killactive, # close the active window
          bind = $mainMod SHIFT, L, exec, swaylock # Lock the screen
          bind = $mainMod, M, exec, wlogout --protocol layer-shell # show the logout window
          bind = $mainMod SHIFT, M, exit, # Exit Hyprland all together no (force quit Hyprland)
          bind = $mainMod, E, exec, thunar # Show the graphical file browser
          bind = $mainMod, V, togglefloating, # Allow a window to float
          bind = $mainMod, SPACE, exec, wofi # Show the graphicall app launcher
          bind = $mainMod, P, pseudo, # dwindle
          bind = $mainMod, J, togglesplit, # dwindle
          bind = $mainMod SHIFT, F, fullscreen, 1
          bind = $mainMod, S, exec, grim -g "$(slurp)" - | swappy -f - # take a screenshot

          bind = ,156, exec, rog-control-center # ASUS Armory crate key
          bind = ,211, exec, asusctl profile -n; pkill -SIGRTMIN+8 waybar # Fan Profile key switch between power profiles
          bind = ,121, exec, pamixer -t # Speaker Mute FN+F1
          bind = ,122, exec, pamixer -d 5 # Volume lower key
          bind = ,123, exec, pamixer -i 5 # Volume Higher key
          bind = ,256, exec, pamixer --default-source -t # Mic mute key
          bind = ,232, exec, brightnessctl set 10%- # Screen brightness down FN+F7
          bind = ,233, exec, brightnessctl set 10%+ # Screen brightness up FN+F8
          bind = ,237, exec, brightnessctl -d asus::kbd_backlight set 33%- # Keyboard brightness down FN+F2
          bind = ,238, exec, brightnessctl -d asus::kbd_backlight set 33%+ # Keyboard brightnes up FN+F3
          bind = ,210, exec, asusctl led-mode -n # Switch keyboard RGB profile FN+F4

          bind = $mainMod, h, movefocus, l
          bind = $mainMod, l, movefocus, r
          bind = $mainMod, k, movefocus, u
          bind = $mainMod, j, movefocus, d

          bind = $mainMod, 1, workspace, 1
          bind = $mainMod, 2, workspace, 2
          bind = $mainMod, 3, workspace, 3
          bind = $mainMod, 4, workspace, 4
          bind = $mainMod, 5, workspace, 5
          bind = $mainMod, 6, workspace, 6
          bind = $mainMod, 7, workspace, 7
          bind = $mainMod, 8, workspace, 8
          bind = $mainMod, 9, workspace, 9
          bind = $mainMod, 0, workspace, 10

          bind = $mainMod SHIFT, 1, movetoworkspace, 1
          bind = $mainMod SHIFT, 2, movetoworkspace, 2
          bind = $mainMod SHIFT, 3, movetoworkspace, 3
          bind = $mainMod SHIFT, 4, movetoworkspace, 4
          bind = $mainMod SHIFT, 5, movetoworkspace, 5
          bind = $mainMod SHIFT, 6, movetoworkspace, 6
          bind = $mainMod SHIFT, 7, movetoworkspace, 7
          bind = $mainMod SHIFT, 8, movetoworkspace, 8
          bind = $mainMod SHIFT, 9, movetoworkspace, 9
          bind = $mainMod SHIFT, 0, movetoworkspace, 10

          bind = $mainMod, mouse_down, workspace, e+1
          bind = $mainMod, mouse_up, workspace, e-1

          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow
        '';
      };
    };
  };
}
