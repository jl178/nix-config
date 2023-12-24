{ config, pkgs, inputs, ... }:

{

  # Set your time zone
  time.timeZone = "America/Denver";
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [ font-awesome nerdfonts ];
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  services.nix-daemon.enable = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;
  nixpkgs.config.allowUnfree = true;
  services.yabai.enable = true;
  services.yabai.extraConfig = ''
    yabai -m config                                 \
    mouse_follows_focus          off            \
    focus_follows_mouse          off            \
    window_origin_display        default        \
    window_placement             second_child   \
    window_zoom_persist          on             \
    window_topmost               off            \
    window_shadow                on             \
    window_animation_duration    0.0            \
    window_animation_frame_rate  120            \
    window_opacity_duration      0.0            \
    active_window_opacity        1.0            \
    normal_window_opacity        0.90           \
    window_opacity               off            \
    insert_feedback_color        0xffd75f5f     \
    active_window_border_color   0xff775759     \
    normal_window_border_color   0xff555555     \
    window_border_width          4              \
    window_border_radius         12             \
    window_border_blur           off            \
    window_border_hidpi          on             \
    window_border                off            \
    split_ratio                  0.50           \
    split_type                   auto           \
    auto_balance                 off            \
    top_padding                  20             \
    bottom_padding               20             \
    left_padding                 20             \
    right_padding                20             \
    window_gap                   12             \
    layout                       bsp            \
    mouse_modifier               fn             \
    mouse_action1                move           \
    mouse_action2                resize         \
    mouse_drop_action            swap

    echo "yabai configuration loaded.."
'';
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
  environment.loginShell = pkgs.zsh;

  # User configuration
  # users.defaultUserShell = pkgs.zsh;
  users.users."jered.little" = {
    home = "/Users/jered.little";
    packages = with pkgs; [
      # macOS compatible packages
    ];
  };
  environment.variables = {
    NIX_LDFLAGS="-F${pkgs.darwin.apple_sdk.frameworks.CoreFoundation}/Library/Frameworks -framework CoreFoundation $NIX_LDFLAGS";
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
  ];
}
