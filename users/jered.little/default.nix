{ config, lib, pkgs, inputs, headless ? true, ... }:

{
  imports = [
    ../modules/packages.nix
    ../modules/tmux.nix
    ../modules/btop.nix
    ../modules/zsh.nix
    ./sketchybar.nix
    ./desktop.nix
  ];

  manual.manpages.enable = false;

  home = {
    username = "jered.little";
    homeDirectory = "/Users/jered.little";
    packages = with pkgs; [ zsh git gh ];
  };

  programs.git = {
    enable = true;
    userEmail = "jeredlittle1996@gmail.com";
    userName = "Jered Little";
    extraConfig = {
      safe.directory = [ "*" ];
      credential.helper = "! gh auth git-credential";
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
