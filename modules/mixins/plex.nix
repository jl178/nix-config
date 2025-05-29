{ config, pkgs, lib, ... }:

let
  audiobooksPlugin = pkgs.stdenv.mkDerivation {
    name = "Audiobooks.bundle";
    src = pkgs.fetchurl {
      url =
        "https://github.com/macr0dev/Audiobooks.bundle/archive/9b1de6b66cd8fe11c7d27623d8579f43df9f8b86.zip";
      sha256 =
        "539492e3b06fca2ceb5f0cb6c5e47462d38019317b242f6f74d55c3b2d5f6e1d";
    };
    buildInputs = [ pkgs.unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
in {
  services.plex = {
    enable = true;
    dataDir = "/var/lib/plexmediaserver/";
    openFirewall = false;
    extraPlugins = [
      (builtins.path {
        name = "Audnexus.bundle";
        path = pkgs.fetchFromGitHub {
          owner = "djdembeck";
          repo = "Audnexus.bundle";
          rev = "v1.3.2";
          sha256 = "sha256-BpwyedIjkXS+bHBsIeCpSoChyWCX5A38ywe71qo3tEI=";
        };
      })
      (builtins.path {
        name = "Absolute-Series-Scanner";
        path = pkgs.fetchFromGitHub {
          owner = "ZeroQI";
          repo = "Absolute-Series-Scanner";
          rev = "8ae47b2583f10554e4c9eff89ab8062c4c64bd14";
          sha256 = "sha256-BpwyedIjkXS+bHBsIeCpSoChyWCX5A38ywe71qo3tEI=";
        };
      })

    ];
  };
  networking.firewall = {

    # Kill switch for VPN. Internet will stop working if openvpn is down
    # extraCommands = ''
    #   # Flush the tables. This may cut the system's internet.
    #   iptables -F
    # # The default policy, if no other rules match, is to refuse traffic.
    #   iptables -P OUTPUT DROP
    #   iptables -P INPUT DROP
    #   iptables -P FORWARD DROP
    #
    #   # Let the VPN client communicate with the outside world.
    #   iptables -A OUTPUT -j ACCEPT -m owner --gid-owner openvpn
    #
    #   # The loopback device is harmless, and TUN is required for the VPN.
    #   iptables -A OUTPUT -j ACCEPT -o lo
    #   iptables -A OUTPUT -j ACCEPT -o tun+
    #       
    #   # We should permit replies to traffic we've sent out.
    #   iptables -A INPUT -j ACCEPT -m state --state ESTABLISHED
    # '';
  };
  # Define the media group
  users.groups.mediagroup = { };
  users.groups.openvpn = { };
  services.openvpn = {
    servers.nordvpn = {
      config = "config /etc/openvpn/us6660.nordvpn.com.udp1194.ovpn";
      autoStart = true; # Ensure it starts on boot
      updateResolvConf = true;
    };
  };
  # Add radarr and sonarr to the media group
  users.users.radarr = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };

  users.users.sonarr = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  users.users.plex = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  users.users.deluge = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  users.users.jackett = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  users.users.readarr = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  networking.firewall = {
    allowedTCPPorts = [ 3005 8324 32469 80 443 32400 9117 ];
    allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 32400 80 443 ];
  };
  services.ombi = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/ombi/";
  };
  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/sonarr/";
  };
  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/radarr/";
  };
  services.deluge = {
    enable = true;
    web.enable = true;
    openFirewall = true;
    web.openFirewall = true;
    dataDir = "/var/lib/deluge/";
    group = "mediagroup";
  };
  services.jackett = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/jackett/";
  };
  services.readarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/readarr/";
  };
  services.calibre-web = {
    enable = true;
    openFirewall = true;
    listen.ip = "0.0.0.0";
  };
  services.netbird.enable = true;
}
