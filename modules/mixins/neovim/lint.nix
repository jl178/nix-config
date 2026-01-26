{ config, pkgs, inputs, ... }: {
  programs.nixvim.plugins.lint = {
    enable = true;
    lintersByFt = {
      # json = [ "jsonlint" ];
      markdown = [ "vale" ];
      terraform = [ "tflint" "tfsec" ];
      yaml = [ "yamllint" ];
      python = [ "ruff" ];
    };
  };
  environment.systemPackages = with pkgs; [
    # nodePackages.jsonlint
    vale
    tflint
    tfsec
    yamllint
    ruff
  ];
}
