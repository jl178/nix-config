{ config, pkgs, inputs, ... }:

{

  # Set your time zone
  time.timeZone = "America/Denver";
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [ font-awesome nerdfonts ];

  services.nix-daemon.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Home Manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = import "${inputs.self}/users/jeredlittle.nix";
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
  };

  # Enable programs
  programs.zsh.enable = true;
  environment.loginShell = pkgs.zsh;

  # User configuration
  # users.defaultUserShell = pkgs.zsh;
  users.users.jeredlittle = {
    home = "/Users/jeredlittle";
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
  ];
}
