{ config, pkgs, lib, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false; # Use proprietary drivers
  };
}
