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
  # Jackett is on its way out, replaced by Prowlarr below, but both run for
  # now: Sonarr and Radarr still point their Torznab indexers at
  # localhost:9117, and deleting Jackett before those are re-pointed would
  # take every indexer down at once. Retire it once Prowlarr's sync has
  # populated the *arrs (Prowlarr -> Settings -> Apps).
  services.jackett = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/jackett/";
  };

  # Prowlarr, indexer manager. Unlike Jackett it pushes indexer definitions
  # into Sonarr/Radarr/Readarr itself rather than being pasted in per app, it
  # manages Newznab (Usenet) next to Torznab in one place, and its definitions
  # track upstream more closely -- Jackett here is old enough to warn about it
  # on startup and had already dropped the animetosho definition. Web UI :9696.
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # Bazarr, subtitles. Watches the Sonarr/Radarr libraries and fetches subs to
  # match. Web UI :6767.
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "mediagroup";
  };

  # Overseerr, request frontend. Replaces Ombi, which never connected to Plex
  # properly here. Overseerr is built specifically for Plex: it authenticates
  # with Plex OAuth, imports the libraries and user list, and syncs the Plex
  # Watchlist, so adding something to your watchlist in Plex turns into a
  # request that lands in Radarr/Sonarr automatically. Plex lives on
  # 192.168.1.56:32400, which the kill-switch permits as LAN traffic.
  #
  # Ombi is deliberately left enabled above so its existing request history is
  # still reachable while you migrate. Remove it once Overseerr is set up.
  services.overseerr = {
    enable = true;
    openFirewall = true;
    port = 5055;
  };

  # Recyclarr, quality automation. This is the piece that addresses junk
  # grabs: it syncs TRaSH Guides custom formats and quality profiles into
  # Sonarr and Radarr on a schedule, scoring releases so known-bad groups,
  # mislabelled encodes and executable payloads are rejected before they are
  # ever sent to the download client.
  #
  # API keys are NOT in this repo -- it is public. They are read at runtime
  # from files via systemd credentials; see LoadCredential below. Populate
  # them with:
  #   sudo install -d -m 0700 /etc/recyclarr
  #   sudo grep -oP '(?<=<ApiKey>)[^<]+' /var/lib/sonarr/config.xml \
  #     | sudo tee /etc/recyclarr/sonarr-api_key >/dev/null
  #   sudo grep -oP '(?<=<ApiKey>)[^<]+' /var/lib/radarr/config.xml \
  #     | sudo tee /etc/recyclarr/radarr-api_key >/dev/null
  #   sudo chmod 0400 /etc/recyclarr/*-api_key
  services.recyclarr = {
    enable = true;
    schedule = "daily";
    configuration = {
      sonarr = [{
        instance_name = "main";
        base_url = "http://localhost:8989";
        api_key._secret = "/run/credentials/recyclarr.service/sonarr-api_key";
        include = [
          { template = "sonarr-quality-definition-series"; }
          { template = "sonarr-v4-quality-profile-web-1080p"; }
          { template = "sonarr-v4-custom-formats-web-1080p"; }
        ];
      }];
      radarr = [{
        instance_name = "main";
        base_url = "http://localhost:7878";
        api_key._secret = "/run/credentials/recyclarr.service/radarr-api_key";
        include = [
          { template = "radarr-quality-definition-movie"; }
          { template = "radarr-quality-profile-hd-bluray-web"; }
          { template = "radarr-custom-formats-hd-bluray-web"; }
        ];
      }];
    };
  };
  systemd.services.recyclarr.serviceConfig.LoadCredential = [
    "sonarr-api_key:/etc/recyclarr/sonarr-api_key"
    "radarr-api_key:/etc/recyclarr/radarr-api_key"
  ];
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
