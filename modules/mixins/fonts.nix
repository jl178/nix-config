{ config, pkgs, lib, ... }:
{
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    font-awesome
    jetbrains-mono
  ];
}
