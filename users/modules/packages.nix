{ config, lib, pkgs, inputs, ... }: {
  imports = [ ];
  # General packages which are used across various programs.
  home = {
    packages = with pkgs; [
      htop
      # gcc
      # clang
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
      kubernetes-helm
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
