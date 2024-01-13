{
  programs.nixvim.plugins.notify = { enable = true; };
  programs.nixvim = {
    extraConfigLua = ''
      require("notify").setup({
        background_colour = "#000000",
      })
    '';
  };
}
