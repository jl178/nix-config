{
  programs.nixvim.plugins.gitsigns = {
    enable = true;
    signs = {
      add.text = "│";
      change.text = "│";
      delete.text = "_";
      topdelete.text = "‾";
      changedelete.text = "~";
      untracked.text = "┆";
    };
  };
}
