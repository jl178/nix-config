{ config, pkgs, inputs, ... }:

let
  icons = {
    cpu = "";
    memory = "";
    date = "";
    microphone = "";
    microphone-muted = "";
    microphone-disconnected = "";
    wifi = "";
    up = "";
    down = "";
    ethernet = "";
    envelope = "";
  };

in {
  config = {
    home-manager.users.jered = { pkgs, ... }: {
      services = {
        polybar = {
          enable = true;
          package = pkgs.polybar.override {
            i3Support = true;
            alsaSupport = true;
            iwSupport = true;
            githubSupport = true;
          };
          script = "polybar bar &";
          extraConfig = ''

            [global/wm]
            # margin-top = 5
            # margin-bottom = 5
            # margin-left = 3
            # margin-right = 3


            [colors]
            ;orange = #FF6200
            ;orange = #d65d0e
            darkgray = ''${xrdb:color8}
            orange = ''${xrdb:color9}
            white = #ebdbb2
            gray = #585858
            black = #090909
            red = #c795ae
            blue = #95aec7
            yellow = #c7ae95
            green = #aec795
            #background = #1f222d
            background = #1D2021
            background-alt = #4e4e4e
            foreground = #ebdbb2
            # foreground = ''${xrdb:foreground}
            foreground-alt = #4e4e4e
            primary = #1f222d
            secondary = #FF6200
            alert = #fb4934

            [bar/bar]
            bottom = false
            ; wm-restack = i3
            ; width = 1344
            height = 26
             offset-x = 20
             offset-y = 20

            locale = en_US.UTF-8

            enable-ipc = true

            # padding-left = 5
            # padding-right = 5

            module-margin-right = 0
            module-margin-left = 0

            modules-right = separator battery separator cpu separator memory separator network separator volume
            modules-left = nix-label separator i3 separator date separator
            modules-center = xwindow

            background = ''${colors.background}
            foreground = ''${colors.foreground}

            underline-size = 0
            underline-color = ''${colors.white}

            tray-detached = false
            tray-position =
            tray-offset-x = 0
            tray-offset-y = 0
            ;tray-maxsize = 16
            tray-padding = 0
            tray-transparent = false
            tray-scale = 1.0

            font-0 = "JetBrainsMono:size=10:weight=bold;2"
            font-1 = Font Awesome 6 Free:pixelsize=12;2
            font-2 = Font Awesome 6 Free Solid:pixelsize=12;2
            font-3 = Font Awesome 6 Brands:pixelsize=12;2
            font-4 = "JetBrainsMono Nerd Font:size=15:weight=bold;2"

            [module/nix-label]
            type = custom/text
            content = %{F#928374}󱄅%{F-}
            content-padding = 2

            [module/battery]
            type = internal/battery

            full-at = 95
            low-at = 15
            battery = BAT0
            adapter = ADP1
            poll-interval = 5

            time-format = %H:%M
            format-charging = <animation-charging> <label-charging>
            format-discharging = <ramp-capacity> <label-discharging>
            format-full = <ramp-capacity> <label-full>
            format-low = <label-low> <animation-low>
            format-charing-padding = 2
            format-discharing-padding = 2
            format-full-padding = 2

            label-charging = %percentage%%
            label-discharging = %percentage%%
            label-full = %percentage%%
            label-low = %percentage%%

            ramp-capacity-0 = %{F#928374}%{F-}
            ramp-capacity-1 = %{F#928374}%{F-}
            ramp-capacity-2 = %{F#928374}%{F-}
            ramp-capacity-3 = %{F#928374}%{F-}
            ramp-capacity-4 = %{F#928374}%{F-}

            bar-capacity-width = 10

            animation-charging-0 = %{F#928374}%{F-}
            animation-charging-1 = %{F#928374}%{F-}
            animation-charging-2 = %{F#928374}%{F-}
            animation-charging-3 = %{F#928374}%{F-}
            animation-charging-4 = %{F#928374}%{F-}

            animation-charging-framerate = 750

            animation-discharging-0 = %{F#928374}%{F-}
            animation-discharging-1 = %{F#928374}%{F-}
            animation-discharging-2 = %{F#928374}%{F-}
            animation-discharging-3 = %{F#928374}%{F-}
            animation-discharging-4 = %{F#928374}%{F-}
            animation-discharging-framerate = 500

            animation-low-0 = !
            animation-low-1 =
            animation-low-framerate = 200

            [module/cpu]
            type = internal/cpu

            ; Seconds to sleep between updates
            ; Default: 1
            interval = 0.5
            format = <label>
            label = %{F#928374} %{F-} %percentage%%
            format-padding = 2

            [module/memory]
            type = internal/memory

            ; Seconds to sleep between updates
            ; Default: 1
            interval = 3
            format = <label>
            label = %{F#928374} %{F-} %gb_used%/%gb_free%
            format-padding = 2

            # [module/temperature]
            # type = internal/temperature
            #
            # interval = 0.5
            #
            # thermal-zone = 0
            #
            # base-temperature = 20
            # format = <label>
            # format-padding = 2
            # label = %{F#928374}%{F-} %temperature-c%

            [module/i3]
            type = internal/i3
            format = <label-state> <label-mode>
            format-padding = 2
            label-focused = %index%
            label-focused-foreground = ''${colors.foreground}
            label-focused-padding = 1
            label-focused-background = ''${colors.background-alt}
            label-focused-underline= ''${colors.foreground}

            label-unfocused = %index%
            label-unfocused-padding = 1

            label-visible = %index%
            label-visible-padding = 1

            label-urgent = %index%
            label-urgent-background = ''${colors.alert}
            label-urgent-padding = 1

            label-separator = |
            label-separator-padding = 1

            [module/xwindow]
            type = internal/xwindow
            max-length = 50

            [module/date]
            type = internal/date
            #date-alt =   %A %H:%M
            date = %{F#928374} %{F-} %Y-%m-%d %I:%M %p
            interval = 5
            format-underline = ''${colors.white}
            ;format-background = ''${colors.black}
            format-foreground = ''${colors.foreground}
            format-padding = 2

            label-separator = ┃

            [module/volume]
            type = internal/volume

            format-volume = <label-volume>
            format-volume-padding = 2

            format-volume-underline = ''${colors.white}

            label-volume = %{F#928374} %{F-}%percentage:3%%
            #label-volume-foreground = ''${color.white}

            label-muted =%{F#928374} %{F-}mute
            format-muted = <label-muted>
            format-muted-underline = ''${colors.white}
            format-muted-padding = 2
            #label-muted-foreground = ''${colors.gray}

            format-padding = 2

            [module/network]
            type = internal/network
            interface = wlp0s20f3

            ; Seconds to sleep between updates
            ; Default: 1
            interval = 3.0

            ; Test connectivity every Nth update
            ; A value of 0 disables the feature
            ; NOTE: Experimental (needs more testing)
            ; Default: 0
            ;ping-interval = 3

            ; @deprecated: Define min width using token specifiers (%downspeed:min% and %upspeed:min%)
            ; Minimum output width of upload/download rate
            ; Default: 3

            ; Accumulate values from all interfaces
            ; when querying for up/downspeed rate
            ; Default: false
            accumulate-stats = true

            format-connected-padding = 2
            format-disconnected-padding = 2
            format-connected-underline = ''${colors.white}
            format-disconnected-underline = ''${colors.white}

            ; Available tags:
            ;   <label-connected> (default)
            ;   <ramp-signal>
            format-connected = %{F#928374} %{F-}<label-connected>

            ; Available tags:
            ;   <label-disconnected> (default)
            format-disconnected = <label-disconnected>

            ; Available tags:
            ;   <label-connected> (default)
            ;   <label-packetloss>
            ;   <animation-packetloss>
            format-packetloss = <animation-packetloss> <label-connected>

            ; Available tokens:
            ;   %ifname%    [wireless+wired]
            ;   %local_ip%  [wireless+wired]
            ;   %essid%     [wireless]
            ;   %signal%    [wireless]
            ;   %upspeed%   [wireless+wired]
            ;   %downspeed% [wireless+wired]
            ;   %linkspeed% [wired]
            ; Default: %ifname% %local_ip%
            label-connected = %signal:3%%

            ; Available tokens:
            ;   %ifname%    [wireless+wired]
            ; Default: (none)
            label-disconnected = %{F#928374} %{F-}none

            ; Available tokens:
            ;   %ifname%    [wireless+wired]
            ;   %local_ip%  [wireless+wired]
            ;   %essid%     [wireless]
            ;   %signal%    [wireless]
            ;   %linkspeed% [wired]
            ; Default: (none)
            ;label-packetloss = %essid%
            ;label-packetloss-foreground = #eefafafa

            ; Only applies if <animation-packetloss> is used
            animation-packetloss-0 = ⚠
            animation-packetloss-1 = 📶
            ; Framerate in milliseconds
            animation-packetloss-framerate = 500

            [module/separator]
            type = custom/text
            content = ┃
            content-foreground = #4e4e4e

            ; vim:ft=dosini
          '';
        };
      };
    };
  };
}
