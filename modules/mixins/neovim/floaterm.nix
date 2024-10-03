{
  programs.nixvim.plugins.floaterm = {
    enable = true;
    # direction = "float";
    shell = "zsh";
    keymaps.toggle = "<leader>tf";
    # insertMappings = false;
    # highlights = {
    #   Normal = { guibg = "NONE"; };
    #   NormalFloat = { link = "NONE"; };
    #   FloatBorder = {
    #     guifg = "NONE";
    #     guibg = "NONE";
    #   };
    # };
  };
}
