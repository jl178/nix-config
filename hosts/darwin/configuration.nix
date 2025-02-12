{ config, pkgs, inputs, lib, ... }:

{
  imports = with inputs.self.nixosModules; [ mixins-neovim ];
  # Set your time zone
  time.timeZone = "America/Denver";
  fonts.packages = [ pkgs.font-awesome ]
    ++ builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  ids.uids.nixbld = 300;
  nix.enable = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;
  nixpkgs.config.allowUnfree = true;
  services.aerospace.enable = true;
  ids.gids.nixbld = 30000;
  services.aerospace.settings = {
    after-startup-command = [ "exec-and-forget sketchybar" ];
    gaps = {
      outer.left = 30;
      outer.bottom = 30;
      outer.top = 60;
      outer.right = 30;
      inner.horizontal = 20;
      inner.vertical = 20;
    };

    mode.main.binding = {
      cmd-shift-enter =
        "exec-and-forget /run/current-system/sw/bin/wezterm start";
      cmd-h = "focus --boundaries-action wrap-around-the-workspace left";
      cmd-j = "focus --boundaries-action wrap-around-the-workspace down";
      cmd-k = "focus --boundaries-action wrap-around-the-workspace up";
      cmd-l = "focus --boundaries-action wrap-around-the-workspace right";

      cmd-shift-h = "move left";
      cmd-shift-j = "move down";
      cmd-shift-k = "move up";
      cmd-shift-l = "move right";

      cmd-shift-f = "fullscreen";

      cmd-shift-space = "layout floating tiling";

      cmd-1 = "workspace 1";
      cmd-2 = "workspace 2";
      cmd-3 = "workspace 3";
      cmd-4 = "workspace 4";
      cmd-5 = "workspace 5";
      cmd-6 = "workspace 6";
      cmd-7 = "workspace 7";
      cmd-8 = "workspace 8";
      cmd-9 = "workspace 9";
      cmd-0 = "workspace 10";

      cmd-shift-1 = "move-node-to-workspace 1";
      cmd-shift-2 = "move-node-to-workspace 2";
      cmd-shift-3 = "move-node-to-workspace 3";
      cmd-shift-4 = "move-node-to-workspace 4";
      cmd-shift-5 = "move-node-to-workspace 5";
      cmd-shift-6 = "move-node-to-workspace 6";
      cmd-shift-7 = "move-node-to-workspace 7";
      cmd-shift-8 = "move-node-to-workspace 8";
      cmd-shift-9 = "move-node-to-workspace 9";
      cmd-shift-0 = "move-node-to-workspace 10";

      cmd-shift-c = "reload-config";

      cmd-r = "mode resize";
    };

    mode.resize.binding = {
      h = "resize width -50";
      j = "resize height +50";
      k = "resize height -50";
      l = "resize width +50";
      enter = "mode main";
      esc = "mode main";
    };
  };

  # Additional i3-like configuration
  services.aerospace.settings.enable-normalization-flatten-containers = false;
  services.aerospace.settings.enable-normalization-opposite-orientation-for-nested-containers =
    false;
  services.aerospace.settings.on-focused-monitor-changed =
    [ "move-mouse monitor-lazy-center" ];

  services.aerospace.settings.exec-on-workspace-change = [
    "/bin/bash"
    "-c"
    "/run/current-system/sw/bin/sketchybar --trigger aerospace_workspace_change AEROSPACE_FOCUSED_WORKSPACE=$(/run/current-system/sw/bin/aerospace list-workspaces --focused)"
  ];
  services.sketchybar.enable = true;
  services.jankyborders.enable = true;
  services.jankyborders.active_color = "0x99d79921";
  services.jankyborders.inactive_color = "0xFF282828"; # Solid dark gray

  # Home Manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = import "${inputs.self}/users/jered.little.nix";
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
  };
  system.defaults.dock.autohide = true;
  # Enable programs
  programs.zsh.enable = true;
  # environment.loginShell = pkgs.zsh;

  # User configuration
  # users.defaultUserShell = pkgs.zsh;
  users.users."jered.little" = {
    home = "/Users/jered.little";
    packages = with pkgs;
      [
        # macOS compatible packages
      ];
  };
  environment.variables = {
    NIX_LDFLAGS =
      "-F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS";
  };
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim
    git
    mktemp
    darwin.apple_sdk.frameworks.System
    darwin.apple_sdk.frameworks.CoreFoundation
    wezterm
    kitty
    docker-credential-helpers
  ];

  system.stateVersion = 5;
}
