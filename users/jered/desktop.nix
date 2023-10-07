{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # ./modules/wezterm.nix
    ./modules/waybar.nix
    ./modules/hyprland.nix
  ];
  home = {
    packages = with pkgs; [
      logseq
      quasselClient
      alsa-utils
      wdisplays
      inkscape
      gimp
      mumble
      zathura
      pavucontrol
      qbittorrent
      thunderbird
      wl-mirror
      signal-desktop
    ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
  
  gtk = {
    enable = true;
    theme.package = pkgs.arc-theme;
    theme.name = "Arc-Dark";
    iconTheme.package = pkgs.arc-icon-theme;
    iconTheme.name = "Arc";
  };

  xdg.enable = true;
}
