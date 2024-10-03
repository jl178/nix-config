{ config, pkgs, lib, ... }: {
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    layout = "us";
    enable = true;
    dpi = 90;


    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
        defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
     ];
    };
  };
  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
}
