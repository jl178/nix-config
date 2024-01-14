# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, ... }:

{
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    mixins-fonts
    mixins-nvidia
    # mixins-i3
    # mixins-xorg
    # mixins-picom
    # mixins-polybar
    mixins-wayland
    mixins-hyprland
    mixins-waybar
    mixins-neovim
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = import "${inputs.self}/users";
    extraSpecialArgs = {
      inherit inputs;
      headless = false;
    };
  };

  nix = {
    # From flake-utils-plus
    generateNixPathFromInputs = true;
    generateRegistryFromInputs = true;
    linkInputs = true;
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
  networking.extraHosts = ''
    3.219.239.5 registry-1.docker.io
  '';
  networking.enableIPv6 = false;
  boot.kernelParams = [ "ipv6.disable=1" ];
  # Set your time zone.
  time.timeZone = "America/Denver";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  virtualisation.docker.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
    touchpad.scrollMethod = "twofinger";
    touchpad.disableWhileTyping = true;
    touchpad.clickMethod = "clickfinger";

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  # Ensure the 'nixosgroup' exists
  users.groups.nixosgroup = { };

  # Activation script to recursively set permissions using chmod
  system.activationScripts.setPermissions = {
    text = ''
      chown -R :nixosgroup /etc/nixos/
      chmod -R 770 /etc/nixos/
    '';
  };
  users.users.jered = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "docker" "nixosgroup" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      (wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      winetricks
    ];

  };

  # Default to battery saver mode on boot - Add sleep of 5 seconds to ensure PowerDaemon is available.
  systemd.services.system76power = {
    script = ''
      sleep 5
      ${config.boot.kernelPackages.system76-power}/bin/system76-power profile battery
    '';
    wantedBy = [ "multi-user.target" ];
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    killall
    git
    kitty
    wezterm
    swaybg
    pavucontrol
    zsh
    steam-run
    powertop
    feh
    brightnessctl
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
