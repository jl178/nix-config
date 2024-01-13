{
  programs.nixvim.plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
    sources.formatting = {
      black.enable = true;
      eslint.enable = true;
      nixfmt.enable = true;
      jq.enable = true;
      gofmt.enable = true;
      sqlfluff.enable = true;
      trim_whitespace.enable = true;
      stylua.enable = true;
      beautysh.enable = true;
    };
  };
}
