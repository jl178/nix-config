{ pkgs, homeConfiguration, name ? "nix-dev", tag ? "latest", stream ? false }:

# Docker image built from the container Home Manager generation.
#
# "Nix in Docker": the image carries the whole store closure of the generation
# plus a populated Nix database, so `nix`, `nix develop` and `home-manager
# switch` all work inside the container.
#
# The home directory is materialised at build time (the generation's
# `home-files` tree is copied in) rather than activated on first start, so the
# container comes up with dotfiles already in place and no writable-state
# bootstrap.
let
  inherit (pkgs) lib;

  hm = homeConfiguration.activationPackage;
  homeDir = homeConfiguration.config.home.homeDirectory;
  # Path relative to the image root; extraCommands runs with cwd = image root.
  homeRel = lib.removePrefix "/" homeDir;

  passwdFile = pkgs.writeText "passwd" ''
    root:x:0:0:root:${homeDir}:/bin/zsh
    nobody:x:65534:65534:nobody:/var/empty:/bin/false
  '';

  groupFile = pkgs.writeText "group" ''
    root:x:0:
    nogroup:x:65534:
  '';

  shadowFile = pkgs.writeText "shadow" ''
    root:!:1::::::
    nobody:!:1::::::
  '';

  nsswitchFile = pkgs.writeText "nsswitch.conf" ''
    passwd: files
    group: files
    hosts: files dns
  '';

  shellsFile = pkgs.writeText "shells" ''
    /bin/sh
    /bin/bash
    /bin/zsh
  '';

  osReleaseFile = pkgs.writeText "os-release" ''
    NAME="Nix dev container"
    ID=nix-dev
    PRETTY_NAME="Nix dev container"
  '';

  # build-users-group must be empty: there is no nixbld group in the image and
  # sandboxing needs privileges the container usually will not have.
  nixConfFile = pkgs.writeText "nix.conf" ''
    experimental-features = nix-command flakes
    build-users-group =
    sandbox = false
    trusted-users = root
    max-jobs = auto
  '';

  # Anchors the generation in the image so its full closure ends up in the Nix
  # database and in the GC roots, not just on disk.
  hmGeneration = pkgs.runCommand "hm-generation" { } ''
    mkdir -p $out/etc/home-manager
    ln -s ${hm} $out/etc/home-manager/generation
  '';

  contents = [
    # Every package from the Home Manager profile, so /bin has the same tools
    # the shell would put on PATH.
    homeConfiguration.config.home.path
    hmGeneration
    pkgs.dockerTools.binSh
    pkgs.dockerTools.usrBinEnv
    pkgs.dockerTools.caCertificates
  ] ++ (with pkgs; [
    bashInteractive
    coreutils
    diffutils
    findutils
    gnugrep
    gnused
    gnutar
    gzip
    xz
    iana-etc
    less
    nix
    procps
    shadow
    tzdata
    util-linux
    which
  ]);

  mkImage = if stream then
    (args: pkgs.dockerTools.streamLayeredImage (args // { includeNixDB = true; }))
  else
    pkgs.dockerTools.buildLayeredImageWithNixDb;

in mkImage {
  inherit name tag contents;
  # Well above the number of top-level closure entries, so the popularity
  # heuristic can give big things like the JDK and the cloud SDKs their own
  # layers instead of collapsing them together.
  maxLayers = 120;

  extraCommands = ''
    mkdir -p etc/nix tmp var/tmp ${homeRel}
    chmod 1777 tmp var/tmp

    cp ${passwdFile}     etc/passwd
    cp ${groupFile}      etc/group
    cp ${shadowFile}     etc/shadow
    cp ${nsswitchFile}   etc/nsswitch.conf
    cp ${shellsFile}     etc/shells
    cp ${osReleaseFile}  etc/os-release
    cp ${nixConfFile}    etc/nix/nix.conf
    chmod 0644 etc/passwd etc/group etc/nsswitch.conf etc/shells etc/os-release etc/nix/nix.conf
    chmod 0600 etc/shadow

    # Materialise the home directory. Files inside are symlinks into the store;
    # only the directories need to be made writable so the shell can create
    # history, caches and state next to them.
    cp -a ${hm}/home-files/. ${homeRel}/
    find ${homeRel} -type d -exec chmod u+w {} +

    # Deliberately no ~/.nix-profile symlink. Pointing it at the generation's
    # home-path would resolve into the store, and `home-manager switch` inside
    # the container then dies with "creating a garbage collector root ... is
    # forbidden" when it installs packages into the profile directory. Leaving
    # it absent lets Home Manager create a real profile under
    # /nix/var/nix/profiles on the first switch; until then /bin already has
    # every package, so nothing in the home directory depends on it.

    # Runtime state and the bind-mount target for the host's ~/workplace.
    mkdir -p ${homeRel}/.cache ${homeRel}/.local/share ${homeRel}/.local/state \
             ${homeRel}/.config/gh ${homeRel}/.config/github-copilot \
             ${homeRel}/.codex ${homeRel}/workplace
  '';

  config = {
    Cmd = [ "/bin/zsh" ];
    WorkingDir = "${homeDir}/workplace";
    Env = [
      "HOME=${homeDir}"
      "USER=root"
      "SHELL=/bin/zsh"
      "PATH=${homeDir}/.nix-profile/bin:/bin:/usr/bin:/sbin:/usr/sbin"
      "TERM=xterm-256color"
      "TERMINFO_DIRS=/share/terminfo"
      "PAGER=less"
      "EDITOR=nvim"
      "LANG=C.UTF-8"
      "LC_ALL=C.UTF-8"
      "LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive"
      "TZ=America/Denver"
      "TZDIR=${pkgs.tzdata}/share/zoneinfo"
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "GIT_SSL_CAINFO=/etc/ssl/certs/ca-bundle.crt"
      "NIX_PATH=nixpkgs=flake:nixpkgs"
    ];
    Labels = {
      "org.opencontainers.image.title" = name;
      "org.opencontainers.image.description" =
        "Nix dev container built from nix-config";
      "org.opencontainers.image.source" =
        "https://github.com/jeredlittle/nix-config";
    };
  };
}
