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
  # Define the media group
  users.groups.mediagroup = { };
  users.users.plex = {
    isSystemUser = true;
    extraGroups = [ "mediagroup" ];
  };
  networking.firewall = {
    allowedTCPPorts = [ 3005 8324 32469 80 443 32400 9117 ];
    allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 32400 80 443 ];
  };
  services.netbird.enable = true;
}
