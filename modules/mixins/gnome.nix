{ config, pkgs, lib, ... }: {
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Remove GNOME bloat - add back anything you want
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    gnome-music
  ];
}
