{ inputs, lib, ... }:
let
  # Every flake input except this repo itself. Non-flake inputs have no
  # `outputs` and cannot go in the registry.
  flakeInputs =
    lib.filterAttrs (name: input: name != "self" && input ? outputs) inputs;
in {
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    # Let jered push locally built systems to this host. nixos-rebuild
    # --target-host copies the closure as the SSH user, and the daemon refuses
    # unsigned (locally built) paths from anyone not in trusted-users, so
    # without this every remote deploy fails at the copy step. jered is
    # already in wheel everywhere, so this grants nothing new.
    trusted-users = [ "root" "jered" ];
  };

  # Pin every flake input in the registry and on NIX_PATH, so `nix shell
  # nixpkgs#foo`, `nix repl -f '<nixpkgs>'` and friends resolve to exactly the
  # revisions in flake.lock instead of fetching whatever is current. This is
  # what flake-utils-plus' generateRegistryFromInputs / generateNixPathFromInputs
  # / linkInputs did. `nixpkgs` itself is left out of the registry here because
  # NixOS has pinned it natively since 24.05 (nixpkgs.flake.setFlakeRegistry);
  # defining it twice would be two competing definitions of the same entry.
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; })
    (removeAttrs flakeInputs [ "nixpkgs" ]);
  nix.nixPath = lib.mapAttrsToList (name: _: "${name}=flake:${name}") flakeInputs;

  # nh wraps nixos-rebuild with a build graph and a package diff before
  # activation. Its cleaner replaces nix.gc (the two must not both be enabled):
  # unlike nix-collect-garbage it also removes stale gcroots such as old
  # `result` symlinks and direnv caches, and --keep guarantees a few
  # generations survive even if the host has not been rebuilt in 30 days.
  #
  # nh picks the flake output by hostname, and the hostnames here do not match
  # the output names, so pass it: `nh os switch -H oryp11`.
  programs.nh = {
    enable = true;
    flake = "/etc/nixos/nix-config";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 30d --keep 5";
    };
  };
}
