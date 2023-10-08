{ config, lib, pkgs, inputs, ... }: {
  imports = [
    # ./modules/wezterm.nix # Wezterm doesn't work well on Wayland/Hyprland
    ./modules/kitty.nix
  ];
  home = { packages = with pkgs; [ google-chrome ]; };
  xdg.enable = true;
}
