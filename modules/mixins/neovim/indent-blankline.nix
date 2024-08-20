{
  programs.nixvim.plugins.indent-blankline = {
    enable = true;
    settings.indent.char = "┊";
    settings.scope = {
      enabled = true;
      showStart = true;
      showEnd = false;
    };
  };
}
