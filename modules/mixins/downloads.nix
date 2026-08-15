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
  # No users.users.jackett here any more. It only added the service account to
  # mediagroup; the account itself, and crucially its primary group, came from
  # services.jackett. With that disabled the module stops defining the group
  # and this bare declaration trips the "users.users.jackett.group is unset"
  # assertion, which fails evaluation for the whole host.
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
  # Jackett is retired. Prowlarr replaced it and the Torznab indexers that
  # pointed at localhost:9117 have been deleted from both Sonarr and Radarr,
  # so nothing references it any more. Its state is left at /var/lib/jackett
  # rather than deleted, in case a definition needs recovering.
  #
  # Two indexers were lost in the move and are worth knowing about: therarbg
  # has no Prowlarr definition at all, and thepiratebay has one but fails
  # validation. Knaben was added partly to cover that gap -- it is a
  # meta-search across many trackers rather than a single site.
  services.jackett.enable = false;

  # SABnzbd, the Usenet download client. Installed ahead of having an
  # account so the plumbing is ready; it does nothing until a news server is
  # configured in its UI.
  #
  # Usenet is the fix for the class of problem torrents keep producing here:
  # no swarm means no faked seeder counts, no dead trackers, no DHT-harvested
  # infohashes that resolve to nobody. A release either exists on the
  # provider or it does not, and it arrives at line speed.
  #
  # In mediagroup so it can hardlink into the libraries rather than copy. The
  # download directory deliberately sits on /mnt/zfs alongside them - a
  # cross-filesystem move would force a full copy of every import, which is
  # exactly the mistake the deluge downloads folder was making.
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    group = "mediagroup";
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

  # The nixpkgs recyclarr module is written against 7.x and builds its
  # ExecStart as `recyclarr sync --app-data <dir> --config <file>`. 8.x
  # removed --app-data ("Unknown option 'app-data'") in favour of the
  # RECYCLARR_CONFIG_DIR environment variable, so the unit has to be
  # rewritten to match the package we pinned above. --config is unchanged.
  systemd.services.recyclarr = {
    environment.RECYCLARR_CONFIG_DIR = "/var/lib/recyclarr";
    serviceConfig.ExecStart = lib.mkForce
      "${lib.getExe config.services.recyclarr.package} sync --config /var/lib/recyclarr/config.json";
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
      # mediagroup, not "deluge": services.deluge.group is set to mediagroup
      # above and no group named deluge exists, so requesting one fails the
      # unit at 216/GROUP before the script ever runs.
      Group = "mediagroup";
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

  # Jellyseerr, the maintained successor to Overseerr. Runs alongside it on
  # :5056 rather than replacing it, so the existing request history stays
  # reachable while you migrate.
  #
  # Overseerr is not merely stale, it is finished: the repository was
  # archived read-only on 15 Feb 2026 at v1.34.0. Plex then changed their
  # watchlist API and Overseerr logs
  #   Plex.TV Metadata API - Failed to retrieve watchlist items
  #   {"errorMessage":"Request failed with status code 404"}
  # on every sync, which is sct/overseerr#4224, #4228, #4230 and #4260, none
  # of which can now be fixed upstream.
  #
  # Jellyseerr is the same application with Plex support intact -- the
  # Jellyfin support its description mentions is additive. Pinned to unstable
  # for 3.4.1: stable carries 2.7.3, and while that release does contain
  # "update Plex Watchlist URL", there is a later regression
  # (seerr-team/seerr#2369) whose fix landed after it. 3.4.1 is the newest
  # release and the best chance of a working watchlist; if it still fails,
  # the fix is on develop and this is not solvable from nixpkgs yet.
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    port = 5056;
    package = (import inputs.nixpkgs-latest {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    }).jellyseerr;
  };

  # Recyclarr: syncs TRaSH Guides quality profiles, custom formats and their
  # scores into Sonarr and Radarr on a schedule. This is the piece that stops
  # junk grabs -- releases from known-bad groups and mislabelled encodes get
  # negative scores and are never sent to the download client in the first
  # place, rather than being downloaded and then refused at import.
  #
  # CONFIG FORMAT, v8. Do not reintroduce `include: [{ template = ...; }]`.
  # Upstream states plainly: "The official config-templates repository no
  # longer provides include templates as of v8." That directive now only
  # works with a custom resource provider shipping its own includes.json, so
  # every template id fails to resolve regardless of naming -- which is what
  # broke this before, not the ids themselves. v8 replaces the whole
  # mechanism with a single trash_id per quality profile, pulled straight
  # from the guides.
  #   https://recyclarr.dev/reference/configuration/include/
  #
  # trash_ids below were read out of the cloned guides on this host, at
  # /var/lib/recyclarr/resources/trash-guides/git/official, not copied from
  # a blog post. Verify there if they ever stop matching.
  #
  # API keys are NOT in this repo -- it is public. _secret names the real
  # file on disk and the module's genJqSecretsReplacement generates the
  # matching systemd LoadCredential itself. Do not also declare
  # LoadCredential by hand, and do not point _secret at /run/credentials/...:
  # the generator treats the value as the *source* path, so that makes the
  # credential its own source and the unit dies at 243/CREDENTIALS.
  # Recreate the key files with:
  #   sudo install -d -m 0700 /etc/recyclarr
  #   sudo grep -oP '(?<=<ApiKey>)[^<]+' /var/lib/sonarr/config.xml \
  #     | sudo tee /etc/recyclarr/sonarr-api_key >/dev/null
  #   sudo grep -oP '(?<=<ApiKey>)[^<]+' /var/lib/radarr/config.xml \
  #     | sudo tee /etc/recyclarr/radarr-api_key >/dev/null
  #   sudo chmod 0400 /etc/recyclarr/*-api_key
  services.recyclarr = {
    enable = true;
    schedule = "daily";
    # Stable is 7.4.1, which expects an includes.json the guides repo no
    # longer ships and dies on startup. 8.x reads the current layout.
    package = (import inputs.nixpkgs-latest {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    }).recyclarr;
    # Named-style instances: the attribute name IS the instance name. The
    # array style shown in the upstream nixpkgs example was dropped in v5 and
    # is rejected at runtime with "Found array-style list of instances".
    configuration = {
      # Instance names must be unique across ALL services, not just within
      # one. Naming both of these "main" made recyclarr log
      # 'Duplicate instances: ["main"]' and then die with an out-of-bounds
      # array error -- which the unit reported as a clean success while
      # creating nothing at all.
      sonarr.tv = {
        base_url = "http://localhost:8989";
        api_key._secret = "/etc/recyclarr/sonarr-api_key";
        # quality_definition is deliberately NOT synced from the guide.
        # TRaSH's series definitions set minimum sizes from live-action
        # assumptions - Bluray-1080p at 50.8 MB/min - and that rejects
        # perfectly good encodes. "Big Top Scooby-Doo!" is 81 minutes, so the
        # floor came out at 4.0GB and a legitimate 2.3GB release was refused
        # with "2.3 GB is smaller than minimum allowed 4.0 GB". Animation
        # compresses far better than live action, and on a satellite uplink
        # smaller files are the point rather than a compromise. Every tier is
        # capped at 12.5 MB/min in the app instead, which still rejects
        # obvious fakes while allowing good compact encodes. Re-enabling this
        # line would silently restore the 50.8 floor overnight.
        # Score overrides where the guide's defaults conflict with how this
        # house actually watches things. Recyclarr rewrites these profiles
        # daily, so setting them in Sonarr's UI would be undone overnight;
        # they have to live here.
        custom_formats = [
          {
            # x265 (HD). The guide scores this -10000 on the reasoning that a
            # 1080p x265 release is usually a re-encode of already-compressed
            # source. That is true, and irrelevant here: it rejected things
            # like "Big Top Scooby Doo 2012 1080p BluRay x265" outright, and
            # x265 is roughly half the size for much the same watchability,
            # which matters a lot on a satellite link. Neutral, not preferred.
            trash_ids = [ "47435ece6b99a0b477caf360e79ba0bb" ];
            assign_scores_to = [
              { name = "WEB-1080p"; score = 0; }
              { name = "[Anime] Remux-1080p"; score = 0; }
            ];
          }
          {
            # Dubs Only. The guide scores this -10000 because most anime
            # watchers want subs. This house wants dubs, so a dub-only
            # release is desirable rather than disqualifying.
            trash_ids = [ "9c14d194486c4014d422adc64092d794" ];
            assign_scores_to = [{ name = "[Anime] Remux-1080p"; score = 200; }];
          }
          {
            # Anime Dual Audio. Best of both - English dub plus the original
            # track and subtitles - so score it above dub-only.
            trash_ids = [ "418f50b10f1907201b6cfdf881f467b7" ];
            assign_scores_to = [{ name = "[Anime] Remux-1080p"; score = 500; }];
          }
        ];
        quality_profiles = [
          # WEB-1080p
          {
            trash_id = "72dae194fc92bf828f32cde7744e51a1";
            reset_unmatched_scores.enabled = true;
            min_format_score = 0;
          }
          # [Anime] Remux-1080p. Anime is scored on subgroup rather than
          # source, so the live-action profile is close to useless for it.
          #
          # min_format_score 0 is deliberate and important. The guide ships
          # this profile with a minimum of 100, meaning a release must match
          # preferred custom formats worth 100+ points or Sonarr refuses it
          # outright. In practice that rejected everything: a search returning
          # 264 releases approved zero, with "Custom Formats have score 0
          # below Series profile minimum 100" among the reasons. Junk is still
          # rejected, because that works through NEGATIVE scores (LQ, BR-DISK,
          # Anime LQ Groups at -10000), which are unaffected by this floor.
          {
            trash_id = "20e0fc959f1f1704bed501f23bdae76f";
            reset_unmatched_scores.enabled = true;
            min_format_score = 0;
          }
        ];
      };
      radarr.movies = {
        base_url = "http://localhost:7878";
        api_key._secret = "/etc/recyclarr/radarr-api_key";
        # quality_definition is deliberately NOT synced from the guide.
        # TRaSH's movie definitions set minimum sizes from live-action
        # assumptions - Bluray-1080p at 50.8 MB/min - and that rejects
        # perfectly good encodes. "Big Top Scooby-Doo!" is 81 minutes, so the
        # floor came out at 4.0GB and a legitimate 2.3GB release was refused
        # with "2.3 GB is smaller than minimum allowed 4.0 GB". Animation
        # compresses far better than live action, and on a satellite uplink
        # smaller files are the point rather than a compromise. Every tier is
        # capped at 12.5 MB/min in the app instead, which still rejects
        # obvious fakes while allowing good compact encodes. Re-enabling this
        # line would silently restore the 50.8 floor overnight.
        # Same x265 reasoning as Sonarr above: neutral rather than banned.
        custom_formats = [{
          trash_ids = [ "dc98083864ea246d05a42df0d05f81cc" ];
          assign_scores_to = [
            { name = "HD Bluray + WEB"; score = 0; }
            { name = "Remux + WEB 2160p"; score = 0; }
          ];
        }];
        quality_profiles = [
          # HD Bluray + WEB. The default for essentially everything: 1080p,
          # sensible file sizes, and it grabs quickly on a satellite link.
          {
            trash_id = "d1d67249d3890e49bc12e275d989a7e9";
            reset_unmatched_scores.enabled = true;
            min_format_score = 0;
          }
          # Remux + WEB 2160p, deliberately NOT the default. Reserved for the
          # handful of films worth the disk and the download time (Harry
          # Potter, Lord of the Rings and similar). It also has to exist
          # because those titles already have 2160p files on disk: if their
          # profile did not permit 2160p, Radarr would treat what is already
          # there as an unwanted quality.
          {
            trash_id = "fd161a61e3ab826d3a22d53f935696dd";
            reset_unmatched_scores.enabled = true;
            min_format_score = 0;
          }
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
