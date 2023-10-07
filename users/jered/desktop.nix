{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./modules/wezterm.nix
  ];
  home = {
      packages = with pkgs; [
       google-chrome
    ];
  };
  xdg.enable = true;
}
