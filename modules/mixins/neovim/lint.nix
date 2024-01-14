{
  programs.nixvim.plugins.lint = {
    enable = true;
    lintersByFt = {
      json = [ "jsonlint" ];
      markdown = [ "vale" ];
      terraform = [ "tflint" "tfsec" ];
      yaml = [ "yamllint" ];
      python = [ "ruff" ];
    };
  };
}
