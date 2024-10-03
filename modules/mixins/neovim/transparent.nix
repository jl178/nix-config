{
  programs.nixvim.plugins.transparent = {
    enable = true;

    settings = {
      extra_groups = [
        "FloatBorder"
        "NormalFloat"
        "NeoTreeNormal"
        "NeoTreeNormalNC"
        "NeoTreeEndOfBuffer"
      ];
    };
  };
}
