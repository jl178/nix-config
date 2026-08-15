{
  config,
  pkgs,
  lib,
  inputs,
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

  # Proton VPN port forwarding for Deluge, over NAT-PMP.
  #
  # Without a forwarded port a torrent client can only reach peers that are
  # themselves connectable: nobody can initiate to you, so you see a fraction
  # of each swarm and seed poorly. Nord dropped port forwarding entirely,
  # which is part of why throughput here has been bad. Proton still offers it
  # on P2P servers, and the WireGuard config for this host was generated with
  # NAT-PMP enabled.
  #
  # Proton's leases last 60 seconds, so this is a renewal loop rather than a
  # one-shot: it re-requests every 45s and only reconfigures Deluge when the
  # assigned port actually changes (it is random, and changes on reconnect).
  # Runs as the deluge user so deluge-console can authenticate as localclient.
  systemd.services.proton-portforward = {
    description = "Proton VPN NAT-PMP port forward for Deluge";
    after = [ "wg-quick-proton0.service" "deluged.service" ];
    wants = [ "wg-quick-proton0.service" ];
    requires = [ "deluged.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ libnatpmp deluge coreutils gnugrep ];
    serviceConfig = {
      Type = "simple";
      User = "deluge";
      Group = "deluge";
      Restart = "always";
      RestartSec = 15;
    };
    script = ''
      # NAT-PMP gateway is the tunnel's own gateway, not the LAN router.
      GW=10.2.0.1
      last=""
      while true; do
        # Both protocols must be mapped, and both renew the same lease window.
        natpmpc -a 1 0 udp 60 -g "$GW" >/dev/null 2>&1 || true
        out=$(natpmpc -a 1 0 tcp 60 -g "$GW" 2>/dev/null || true)
        port=$(printf '%s' "$out" | grep -oE 'public port [0-9]+' | grep -oE '[0-9]+' | head -1)
        if [ -n "$port" ] && [ "$port" != "$last" ]; then
          echo "NAT-PMP assigned public port $port; reconfiguring deluge"
          deluge-console "config --set random_port False"            >/dev/null 2>&1 || true
          deluge-console "config --set listen_ports ($port,$port)"   >/dev/null 2>&1 || true
          last=$port
        fi
        sleep 45
      done
    '';
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
  # API keys are NOT in this repo -- it is public. _secret points at the real
  # file on disk and the module's genJqSecretsReplacement generates the
  # matching systemd LoadCredential itself, then substitutes the value into
  # config.json at pre-start. Do not also declare LoadCredential by hand, and
  # do not point _secret at /run/credentials/...: the generator would take
  # that as the *source* path, making it its own source, which fails at unit
  # start with "Failed to set up credentials: Protocol error"
  # (243/CREDENTIALS). The example in the upstream module is misleading here.
  # Populate the key files with:
  #   sudo install -d -m 0700 /etc/recyclarr
  #   sudo grep -oP '(?<=<ApiKey>)[^<]+' /var/lib/sonarr/config.xml \
  #     | sudo tee /etc/recyclarr/sonarr-api_key >/dev/null
  #   sudo grep -oP '(?<=<ApiKey>)[^<]+' /var/lib/radarr/config.xml \
  #     | sudo tee /etc/recyclarr/radarr-api_key >/dev/null
  #   sudo chmod 0400 /etc/recyclarr/*-api_key
  services.recyclarr = {
    enable = true;
    schedule = "daily";
    # Track unstable for this one package. Stable carries 7.4.1, which looks
    # for its template index at repositories/config-templates/includes.json;
    # the upstream config-templates repo now ships templates.json instead, so
    # 7.4.1 clones the repo successfully and then dies with "Recyclarr
    # templates.json does not exist". 8.7.0 reads the current layout. Drop
    # this override once stable catches up.
    package = (import inputs.nixpkgs-latest {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    }).recyclarr;
    # Named-style instances: the attribute name IS the instance name. Recyclarr
    # v5 dropped the array-style list the upstream nixpkgs example still shows
    # ("Found array-style list of instances instead of named-style"), so an
    # array here parses but is then rejected at runtime and the whole config
    # is skipped.
    configuration = {
      sonarr.main = {
        base_url = "http://localhost:8989";
        api_key._secret = "/etc/recyclarr/sonarr-api_key";
        include = [
          { template = "sonarr-quality-definition-series"; }
          { template = "sonarr-v4-quality-profile-web-1080p"; }
          { template = "sonarr-v4-custom-formats-web-1080p"; }
        ];
      };
      radarr.main = {
        base_url = "http://localhost:7878";
        api_key._secret = "/etc/recyclarr/radarr-api_key";
        include = [
          { template = "radarr-quality-definition-movie"; }
          { template = "radarr-quality-profile-hd-bluray-web"; }
          { template = "radarr-custom-formats-hd-bluray-web"; }
        ];
      };
    };
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
