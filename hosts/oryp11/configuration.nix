# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    mixins-nvidia
    mixins-neovim
  ];
  specialisation.i3 = {
    inheritParentConfig = true;
    configuration = {
      imports = with inputs.self.nixosModules; [
        mixins-i3
        mixins-xorg
        mixins-picom
        mixins-polybar
      ];
    };
  };
  specialisation.hyprland = {
    inheritParentConfig = true;
    configuration = {
      imports = with inputs.self.nixosModules; [
        mixins-nvidia
        mixins-wayland
        mixins-hyprland
        mixins-waybar
      ];
    };
  };

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  users.groups.openvpn = { };
  services.openvpn = {
    servers.nordvpn = {
      config = "config /etc/openvpn/us5078.nordvpn.com.udp.ovpn";
      autoStart = true; # Ensure it starts on boot
      updateResolvConf = true;
    };
  };
  services.ollama = {
    enable = true;
    # acceleration = "cuda";
    openFirewall = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "1.1.1.1"
  ];
  networking.extraHosts = ''
    54.227.20.253 registry-1.docker.io
    104.16.103.207 production.cloudflare.docker.com
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
  # sound.enable = true;
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32Bit = true;
    # pulse.enable = true;
  };
  # services.system76-scheduler.settings.processScheduler.pipewireBoost.enable =
  #   true;
  # services.system76-scheduler.settings.processScheduler.pipewireBoost.profile.prio =
  #   20;
  # services.system76-scheduler.settings.processScheduler.pipewireBoost.profile.nice =
  #   -15;
  # services.system76-scheduler.settings.processScheduler.pipewireBoost.profile.ioPrio =
  #   0;
  # services.system76-scheduler.settings.processScheduler.pipewireBoost.profile.ioClass =
  #   "realtime";

  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
      ];
    };
  };
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

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];

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
    extraGroups = [
      "wheel"
      "docker"
      "nixosgroup"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      (wineWowPackages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      winetricks
      brave
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
  hardware.system76.enableAll = true;
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
    slurp
    grim
    nwg-look
    moonlight-qt
    wl-clipboard
    xclip
    appimage-run
  ];
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  services.netbird = {
    enable = true;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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

  networking.firewall = {
    enable = true;

    # Do NOT open generic ports
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];

    # Kill switch rules
    extraCommands = ''
      # Default deny outbound
      iptables -P OUTPUT DROP

      # Allow loopback
      iptables -A OUTPUT -o lo -j ACCEPT

      # Allow established connections
      iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # Allow VPN tunnel traffic
      iptables -A OUTPUT -o tun0 -j ACCEPT

      # ✅ Allow LAN access even if VPN is down
      iptables -A OUTPUT -o eno0 -d 192.168.0.0/24 -j ACCEPT

      # Allow OpenVPN handshake
      iptables -A OUTPUT -o eno0 -p udp --dport 1194 -j ACCEPT
    '';

    extraStopCommands = ''
      # Restore connectivity on shutdown / rollback
      iptables -P OUTPUT ACCEPT
    '';
  };

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
