{ config, pkgs, inputs, ... }: {
  programs.nixvim.plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
    sources.formatting = {
      black.enable = true;
      # biome.enable = true;
      nixfmt.enable = true;
      # jq.enable = true;
      gofmt.enable = true;
      sqlfluff.enable = true;
      # trim_whitespace.enable = true;
      stylua.enable = true;
      shfmt.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    black
    # nodePackages.prettier
    nixfmt
    jq
    sqlfluff
    stylua
    beautysh
  ];
}
