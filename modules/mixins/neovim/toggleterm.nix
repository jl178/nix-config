{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    settings = {
      open_mapping = "tf";
      shell = "zsh";
      direction = "float";
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
  };
}
