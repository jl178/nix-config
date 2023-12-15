{ config, pkgs, lib, ... }:
{
  home = { packages = with pkgs; [ jetbrains-mono kitty ]; };
  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Hard";
    extraConfig = ''
      font_family JetBrains Mono
      font_size 12.0
      background_opacity .75
      map ctrl+shift+r no_op
      cursor_shape block
      shell_integration  no-cursor
      enable_audio_bell no
    '';
  };
}
