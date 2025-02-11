{ config, lib, pkgs, inputs, ... }: {
  imports = [ ];
  # General packages which are used across various programs.
  home = {
    packages = with pkgs; [
      python310Packages.pip
      python310Packages.mysqlclient
      pkg-config
      htop
      # gcc
      # clang
      cmake
      lsd
      python3
      nodejs_18
      fzf
      ripgrep
      lazygit
      kubectl
      k9s
      # kind
      kubernetes-helm
      jdk17
      unzip
      terraform
      ranger
      go
      rustc
      cargo
      docker
      docker-compose
      glab
      azure-cli
      awscli2
      google-cloud-sdk
      mariadb
      airlift
      devbox
      lombok
      tree
      poetry
      lua
    ];
  };
}
