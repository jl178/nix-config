{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    direction = "float";
    shell = "zsh";
    openMapping = "tf";
    insertMappings = false;
    highlights = {
      Normal = { guibg = "NONE"; };
      NormalFloat = { link = "NONE"; };
      FloatBorder = {
        guifg = "NONE";
        guibg = "NONE";
      };
    };
  };
}
