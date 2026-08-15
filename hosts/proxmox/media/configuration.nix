# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports = with inputs.self.nixosModules; [
    ./hardware-configuration.nix
    mixins-common
    # mixins-fonts
    #mixins-i3
    # mixins-xorg
    # mixins-picom
    # mixins-polybar
    mixins-neovim
    mixins-downloads
  ];

  services.openssh = { enable = true; };
  virtualisation.docker.enable = true;
  # nixpkgs still aliases `docker` to docker_28, which is now marked insecure
  # (unmaintained since November 2025) and refuses to evaluate, so *any*
  # rebuild of this host failed regardless of what was being changed. Pin the
  # successor explicitly: 29.4.1 is already the running daemon, so this makes
  # the config agree with reality rather than allowing an insecure package.
  virtualisation.docker.package = pkgs.docker_29;

  services.rpcbind.enable = true;
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/zfs/media 192.168.1.1/24(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 111 2049 20048 32765 32768 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 20048 32765 32768 ];

  fonts.packages = [ pkgs.font-awesome ]
    ++ builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);
  # fileSystems."/mnt/zfs" = {
  #   device =
  #     "5cd8b6f4-bfef-4840-b1f1-47ea7bab3ab9"; # Or the correct device for your setup
  #   fsType = "ext4"; # Or whatever filesystem you're using
  #   options = [ "x-systemd.automount" "nofail" ];
  # }; # Bootloader.
  boot.loader.grub.enable = true;
  # Address the OS disk by its stable by-id path, never by /dev/sdX. Proxmox
  # attaches the 150G system disk as drive-scsi0 and the 34T ZFS pool as
  # drive-scsi1, but Linux enumerates them the other way round, so the pool
  # currently claims /dev/sda. This option said "/dev/sda", i.e. install GRUB
  # onto the media pool: grub-install refused ("embedding is not possible /
  # cross-disk install") and every `nixos-rebuild switch` on this host failed
  # at the bootloader step, which is why the running generation lagged the
  # flake. by-id is immune to that reordering.
  boot.loader.grub.device =
    "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jered = {
    isNormalUser = true;
    description = "jered";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # The shared neovim mixin enables copilot.vim, which is unfree and not wanted
  # on this host. Disabling it here keeps the mixin usable on the workstations.
  programs.nixvim.plugins.copilot-vim.enable = lib.mkForce false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #  wget
    ];
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Prefer IPv4 for outbound connections. The tunnel is configured v4-only
  # (see proton0 below) and the kill-switch denies global v6 egress; the LAN still hands
  # this host a Starlink /64 and a v6 default route via RA, and glibc's
  # default RFC 3484 table ranks native IPv6 above IPv4. Every client that
  # resolved to a AAAA therefore tried the one path that cannot work.
  # Ranking v4-mapped addresses top makes getaddrinfo(3) return IPv4 first,
  # so traffic takes the tunnel. This is address *selection* only: it opens
  # no new egress and leaves LAN IPv6 and the netbird overlay untouched.
  networking.getaddrinfo.precedence = {
    "::ffff:0:0/96" = 100;
  };

  # Proton VPN, WireGuard. Replaces the NordVPN OpenVPN tunnel: that ran in
  # userspace over TCP, which stacks two retransmit timers and collapses on a
  # lossy high-RTT link like Starlink, and it died outright whenever the
  # pinned endpoint went away because OpenVPN needs a live TLS session.
  # WireGuard is in-kernel and stateless, so a missing peer is a pause rather
  # than an outage.
  #
  # The private key is deliberately NOT in this repo. It lives at
  # /etc/wireguard/proton.key, mode 0400 root, matching the convention
  # media_serving already uses for plex.key. Regenerate at
  # account.protonvpn.com -> Downloads -> WireGuard; the endpoint pin in the
  # kill-switch below must be updated in the same commit if the server changes.
  #
  # IPv4 only on purpose. The generated config also carries an IPv6 address
  # and ::/0, and Proton does route v6 (Nord did not), but the kill-switch
  # below still denies global v6. Enabling it means allowing v6 out proton0
  # there as well; doing both at once would have changed two variables in one
  # step, so v6 stays off until the v4 path is confirmed good.
  networking.wg-quick.interfaces.proton0 = {
    address = [ "10.2.0.2/32" ];
    privateKeyFile = "/etc/wireguard/proton.key";
    # No `dns` here. wg-quick would rewrite resolv.conf wholesale and clobber
    # netbird's stub resolver (100.111.55.191, search netbird.cloud). DNS
    # already leaves through the tunnel by virtue of the default route, which
    # is asserted by packet counters rather than assumed.
    peers = [{
      publicKey = "1bWHRIWY3XKNjWoKbdMtzNK5b/zzsgWE74/Tdj0x1yM=";
      endpoint = "95.173.217.220:51820"; # US-TX#580, P2P + NAT-PMP enabled
      allowedIPs = [ "0.0.0.0/0" ];
      persistentKeepalive = 25;
    }];
  };

  # VPN kill-switch rules below use iptables syntax. Pin the firewall
  # backend to iptables explicitly so a future nftables default flip
  # can't silently break the rules.
  networking.nftables.enable = false;
  networking.firewall = {
    enable = true;
    extraCommands = ''
      # The firewall unit reloads on every rebuild and re-runs this script, so
      # it has to be idempotent or each rebuild appends another copy of every
      # rule below. Nothing else on this host installs OUTPUT rules.
      iptables -F OUTPUT
      ip6tables -F OUTPUT

      # Default deny outbound
      iptables -P OUTPUT DROP

      # Allow loopback
      iptables -A OUTPUT -o lo -j ACCEPT

      # Allow established connections
      iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # Allow VPN tunnel traffic
      iptables -A OUTPUT -o proton0 -j ACCEPT

      # ✅ Allow LAN access
      iptables -A OUTPUT -o ens18 -d 192.168.1.1/24 -j ACCEPT

      # ✅ Allow the WireGuard handshake to reach the Proton endpoint.
      # Pinned to US-TX#580. This IP and port must be updated in the same
      # commit as the peer endpoint above, or the tunnel cannot establish and
      # the default-deny policy takes the whole host offline.
      iptables -A OUTPUT -o ens18 -p udp -d 95.173.217.220 --dport 51820 -j ACCEPT

      # Allow the netbird overlay so local tunnelling keeps working.
      iptables -A OUTPUT -o wt0 -j ACCEPT

      # IPv6 kill-switch. Proton does carry IPv6, unlike Nord, but proton0 is
      # deliberately configured v4-only for now, so there is still no tunnelled
      # path for a v6 packet: anything sent over IPv6 would leave via the WAN
      # and expose the real address. Deny by default and allow back only what
      # stays on-link or inside a local tunnel. To enable v6 later, add the
      # address and ::/0 to proton0 and add `ip6tables -A OUTPUT -o proton0
      # -j ACCEPT` here, above the REJECT.
      ip6tables -P OUTPUT DROP
      ip6tables -A OUTPUT -o lo -j ACCEPT
      ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      ip6tables -A OUTPUT -o wt0 -j ACCEPT

      # NDP and router advertisements; IPv6 on the LAN stops working without these.
      ip6tables -A OUTPUT -d fe80::/10 -j ACCEPT
      ip6tables -A OUTPUT -d ff00::/8 -j ACCEPT

      # LAN prefixes. The global /64 is delegated by the ISP, so it must be
      # updated here if the ISP rotates the prefix and LAN IPv6 stops working.
      ip6tables -A OUTPUT -d fdf1:5e61:2b2c::/48 -j ACCEPT
      ip6tables -A OUTPUT -d 2605:59c8:1d54:d008::/64 -j ACCEPT

      # Fail closed *fast*. The policy above already denies, but a DROP is
      # silent: the sender sits in SYN-SENT until its own timeout expires.
      # .NET's HttpClient has no Happy-Eyeballs fallback, so every Jackett
      # request to a v6-resolving tracker stalled the full 100s and Sonarr
      # disabled all indexers. REJECT denies exactly the same traffic but
      # returns an error immediately, so callers fall back to IPv4 at once.
      # This must stay last: it is a catch-all after every ACCEPT above.
      ip6tables -A OUTPUT -j REJECT --reject-with icmp6-adm-prohibited
    '';

    extraStopCommands = ''
      iptables -P OUTPUT ACCEPT
      ip6tables -P OUTPUT ACCEPT
    '';
  };

  # Cloudflare-gated trackers (eztv, 1337x) answer Jackett's plain HTTP
  # request with a challenge page instead of results, which Jackett reports
  # as "Challenge detected but FlareSolverr is not configured". FlareSolverr
  # solves the challenge in a headless browser and hands back the cookie.
  # Deliberately not openFirewall: only Jackett talks to it, over loopback.
  # Its own outbound requests follow the default route through tun0, so the
  # kill-switch covers them exactly like Jackett's.
  services.flaresolverr = {
    enable = true;
    port = 8191;
  };

  # Jackett deliberately tracks the stable pin. 0.24.2200 from nixpkgs-latest
  # was measured against stable 0.24.2108 side by side and returned identical
  # result counts (thepiratebay 100, therarbg 50, limetorrents 40), so the
  # extra input buys nothing here.
  #
  # Note for whoever debugs the anime route next: "Unknown indexer:
  # animetosho" is NOT caused by that choice. Upstream Jackett removed the
  # animetosho definition somewhere after 0.24.1807, and this flake's stable
  # nixpkgs is already past that point -- 0.24.2108 and 0.24.2200 both lack
  # it. The running generation predated the lock bump, which is the only
  # reason it ever worked. Recovering that route means a different indexer
  # (nyaa et al), not a Jackett version change.
}
