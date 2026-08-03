# AeroThemePlasma: recreates the Windows 7 look/feel on KDE Plasma 6.
# Upstream flake: https://github.com/nyakase/aerothemeplasma-nix
# NOTE: this flake targets nixos-unstable; the input follows nixpkgs-latest.
# On first boot into the session a setup wizard finishes applying the theme.
{ config, pkgs, lib, inputs, ... }: {
  imports = [ inputs.aerothemeplasma-nix.nixosModules.aerothemeplasma-nix ];

  boot.plymouth.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "aerothemeplasma";

  programs.aeroshell = {
    enable = true;
    fonts.segoe.enable = true;
    polkit.enable = true;
    # Wayland-only: skip compiling the X11 effects. "aerothemeplasma" is the
    # Wayland session ("aerothemeplasmax11" would be X11).
    sessions.x11.enable = false;
    aerothemeplasma = {
      enable = true;
      sddm.enable = true;
      plymouth.enable = true;
    };
  };
}
