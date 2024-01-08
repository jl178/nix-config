{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ../modules/wezterm.nix # Wezterm doesn't work well on Wayland/Hyprland
    ../modules/kitty.nix
  ];
}
