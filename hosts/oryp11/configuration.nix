# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, lib, ... }:

{
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    mixins-common
    mixins-nvidia
    mixins-neovim
    mixins-proton
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
  programs.nix-ld.enable = true;
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
  specialisation.gnome = {
    inheritParentConfig = true;
    configuration = {
      imports = with inputs.self.nixosModules; [ mixins-nvidia mixins-gnome ];
    };
  };
  specialisation.aerothemeplasma = {
    inheritParentConfig = true;
    configuration = {
      imports = with inputs.self.nixosModules; [
        mixins-nvidia
        mixins-aerothemeplasma
      ];
    };
  };

  fonts.packages = builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);

  # Proton VPN as a declarative WireGuard tunnel, replacing the desktop app
  # for day-to-day use. The app is still installed via mixins-proton for
  # picking an unusual country, but it is no longer what carries traffic.
  #
  # Why: the app creates its WireGuard connection in NetworkManager on demand
  # and DELETES it again on disconnect. That makes it impossible to script --
  # `nmcli con down` works, but there is then nothing left to bring back up,
  # and the app exposes no CLI and no working DBus activation. A bar toggle
  # therefore cannot re-connect through it. This is also the shape the wider
  # community settled on for exactly this reason.
  #
  # The tunnel starts at boot (autostart is the default) and is toggled from
  # waybar via systemctl, which the polkit rule below permits without a
  # password.
  #
  # IPv4 only: this host sets networking.enableIPv6 = false and
  # ipv6.disable=1, so the v6 address and ::/0 from the generated config are
  # deliberately omitted rather than configured and then blackholed.
  #
  # The private key is NOT in this repo. It lives at /etc/wireguard/proton.key,
  # 0400 root. Regenerate at account.protonvpn.com -> Downloads -> WireGuard;
  # the endpoint and public key below must be updated in the same commit.
  networking.wg-quick.interfaces.proton0 = {
    address = [ "10.2.0.2/32" ];
    # Proton's resolver, inside the tunnel. Also required for NetShield (this
    # config was generated at level 2) to do anything, since it filters at the
    # DNS layer.
    dns = [ "10.2.0.1" ];
    privateKeyFile = "/etc/wireguard/proton.key";
    peers = [{
      publicKey = "ZLiSI0SkdK5O0/fhweOpZ2c78F30gWHtsfZcVV0vlj8=";
      endpoint = "95.173.217.219:51820"; # US-TX#467
      allowedIPs = [ "0.0.0.0/0" ];
      persistentKeepalive = 25;
    }];
  };

  # Let the waybar toggle start and stop that one unit without a password.
  # Scoped deliberately: this grants nothing beyond wg-quick-proton0, and is
  # narrower than the sudoers entry the common Arch recipe uses.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "wg-quick-proton0.service" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
  services.ollama = {
    enable = true;
    # Instantiate nixpkgs-latest explicitly rather than reaching into
    # legacyPackages. legacyPackages is a bare import with the *default*
    # config, so it does not inherit nixpkgs.config.allowUnfree from the
    # module system below -- ollama-cuda pulls CUDA, CUDA is unfree, and the
    # whole host refused to evaluate ("Refusing to evaluate package
    # 'cuda12.9-cuda_cudart' ... unfree license (CUDA EULA)"). That failure
    # predates and is independent of anything Proton-related; it simply meant
    # no rebuild of this host could succeed. Same shape as the flake's own
    # containerPkgs helper.
    package = (import inputs.nixpkgs-latest {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    }).ollama-cuda;
    # acceleration = "cuda";
    openFirewall = true;
  };

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
  # networking.extraHosts = ''
  #   54.227.20.253 registry-1.docker.io
  #   104.16.103.207 production.cloudflare.docker.com
  # '';
  networking.enableIPv6 = false;
  boot.kernelParams = [ "ipv6.disable=1" ];
  # Set your time zone.
  time.timeZone = "America/Chicago";
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
  virtualisation.docker.package = pkgs.docker_29;

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
  services.pulseaudio.enable = false;
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
      "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
    };
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad.tapping = true;
    touchpad.naturalScrolling = true;
    touchpad.scrollMethod = "twofinger";
    touchpad.disableWhileTyping = true;
    touchpad.clickMethod = "clickfinger";

  };

  nixpkgs.config.permittedInsecurePackages =
    [ "dotnet-sdk-6.0.428" "aspnetcore-runtime-6.0.36" ];

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
    # networkmanager is required by the Proton VPN client, not just for
    # convenience. The app creates its kill-switch as a NetworkManager system
    # connection, and polkit only grants
    # org.freedesktop.NetworkManager.settings.modify.system to members of this
    # group. Without it connecting fails with
    #   RuntimeError: Error adding KS connection:
    #   nm-settings-error-quark: Insufficient privileges (1)
    # which reads like an app bug but is purely group membership.
    extraGroups = [
      "wheel"
      "docker"
      "nixosgroup"
      "networkmanager"
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
      ${pkgs.system76-power}/bin/system76-power profile battery
    '';
    wantedBy = [ "multi-user.target" ];
  };
  hardware.system76.enableAll = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Proton apps come from mixins-proton, imported above.

    # File encryption. Used for the account-recovery material in ~/.secrets:
    # `age -p` derives the key from a passphrase via scrypt rather than a key
    # file, which matters for recovery documents -- a key file can be lost in
    # the same incident that made you need them.
    age
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
  services.netbird = { enable = true; };
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

  # VPN kill-switch rules below use iptables syntax. Pin the firewall
  # backend to iptables explicitly so a future nftables default flip
  # can't silently break the rules.
  networking.nftables.enable = false;
  networking.firewall = {
    enable = true;

    # Do NOT open generic ports
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];

    # No hand-rolled kill-switch here. The block that used to sit at this spot
    # never enforced anything: its `iptables -P OUTPUT DROP` was commented out,
    # so the policy stayed ACCEPT and every rule under it was a no-op. It also
    # referenced tun0 and eno0, neither of which is what the Proton client
    # brings up. Two competing kill-switches on a roaming laptop produce
    # breakage that is very hard to attribute, so protection here is the
    # Proton app's own, toggled in its UI.
    #
    # The media host is the opposite case and keeps a real default-deny
    # kill-switch, because it is headless, always-on, and must never emit a
    # packet outside its tunnel.
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
