{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    direction = "float";
    shell = "zsh";
    settings = { open_mapping = "tf"; };
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
