{ config, lib, pkgs, inputs, ... }:

# Home Manager configuration for the dev container.
#
# This is the same user environment as the darwin/NixOS hosts (packages, zsh,
# tmux, btop, nixvim) with everything that needs a GUI or a login session left
# out: no wezterm/kitty, no sketchybar/aerospace, no ollama.
#
# It is evaluated standalone (home-manager.lib.homeManagerConfiguration) rather
# than as part of a system config, so the nixvim wrapper has to be imported
# here instead of coming from the NixOS/darwin module list.
{
  imports = [
    ./nixos-compat.nix
    ./clipboard.nix
    inputs.nixvim.homeModules.nixvim
    ../../modules/mixins/neovim.nix
    ../../users/modules/packages.nix
    ../../users/modules/tmux.nix
    ../../users/modules/btop.nix
    ../../users/modules/zsh.nix
  ];

  manual.manpages.enable = false;

  # Ollama runs on the macOS host, so avante's 127.0.0.1 endpoint points at the
  # wrong machine from inside the container.
  programs.nixvim.plugins.avante.settings.ollama.endpoint =
    lib.mkForce "http://host.docker.internal:11434";

  # The container runs as root: Nix single-user mode needs to own /nix, and
  # /nix would have to be chowned into its own image layer otherwise.
  home = {
    username = "root";
    homeDirectory = "/root";
    packages = with pkgs; [
      zsh
      git
      gh
      # Container-only: no system module is around to provide these.
      openssh
      curl
      wget
      gnumake
      gcc
      fd # telescope's file finder
      ncurses # tmux-256color and friends in /share/terminfo
    ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # zsh.nix pins HISTFILE to ~/.zsh_history, which lives in the container's
  # writable layer and dies with the container. Move it under ~/.local/state so
  # the state volume keeps it across rebuilds.
  programs.zsh.initContent = lib.mkAfter ''
    export HISTFILE="$HOME/.local/state/zsh_history"
  '';

  # Lets you re-activate from inside the container:
  #   home-manager switch --flake /workspace/nix-config#container-x86_64-linux
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.email = "jeredlittle1996@gmail.com";
      user.name = "Jered Little";
      safe.directory = [ "*" ];
      credential.helper = "! gh auth git-credential";
    };
  };

  # Fresh home, so this starts at the current release rather than inheriting
  # the "20.03" the other hosts carry. It also has to be >= 20.09: below that
  # Home Manager falls back to the impure `<nixpkgs>` lookup for `pkgsPath`,
  # which a flake evaluation cannot do.
  home.stateVersion = "25.11";
}
