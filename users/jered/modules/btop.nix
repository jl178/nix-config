{ config, pkgs, lib, ... }:

{
  home = { packages = with pkgs; [ btop ]; };
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      theme_background = true;
    };
  };
}
