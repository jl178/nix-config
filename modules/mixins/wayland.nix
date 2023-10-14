{ config, pkgs, lib, ... }: {
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.wallpaper.mode = "fill";
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };
  programs.waybar = { enable = true; };
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    WLR_NO_HARDWARE_CURSORS = "1";
    HYPRLAND_LOG_WLR = "1";
    NIXOS_OZONE_WL = "1";
  };

}
