{ config, lib, pkgs, inputs, ... }:
{
  imports = [
  ];
  home = {
      packages = with pkgs; [
        btop
        tmux
        htop
        # gcc
        clang
        cmake
        lsd
        neovim
        python3
        nodejs_18
        fzf
        ripgrep
        lazygit
        kubectl
        k9s
        kind
        helm
        jdk11
        unzip
        terraform
        ranger
        go
        rustc
        cargo
    ];
  };
}
