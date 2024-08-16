{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    folding = true;
    indent = true;
  };
  programs.nixvim.plugins.treesitter.settings.highlight.enable = true;
  programs.nixvim.plugins.treesitter-textobjects = { enable = true; };
}
