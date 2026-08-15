{
  config,
  pkgs,
  lib,
  ...
}:

let
  audiobooksPlugin = pkgs.stdenv.mkDerivation {
    name = "Audiobooks.bundle";
    src = pkgs.fetchurl {
      url = "https://github.com/macr0dev/Audiobooks.bundle/archive/9b1de6b66cd8fe11c7d27623d8579f43df9f8b86.zip";
      sha256 = "539492e3b06fca2ceb5f0cb6c5e47462d38019317b242f6f74d55c3b2d5f6e1d";
    };
    buildInputs = [ pkgs.unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
in
{
  # Define the media group
  users.groups.mediagroup = { };
  # The VPN tunnel used to be declared here, but it is inseparable from the
  # kill-switch that pins its interface and endpoint, and splitting the two
  # across files is how the endpoint pin went stale and took the host offline
  # (see aa9a300). It now lives beside those rules in the consuming host's
  # configuration.nix.
  # Add radarr and sonarr to the media group
  users.users.radarr = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  users.users.sonarr = {
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
    allowedTCPPorts = [
      3005
      8324
      32469
      80
      443
      32400
      9117
    ];
    allowedUDPPorts = [
      1900
      5353
      32410
      32412
      32413
      32414
      32400
      80
      443
    ];
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
  # services.calibre-web = {
  #   enable = true;
  #   openFirewall = true;
  #   listen.ip = "0.0.0.0";
  # };
  services.netbird.enable = true;
}
