{ config, lib, ... }:

# The neovim mixins are written as NixOS/nix-darwin modules and put the
# linter/formatter binaries their plugins shell out to (vale, tflint, ruff,
# black, stylua, …) into `environment.systemPackages`. Home Manager has no such
# option, so declare it here and fold it into `home.packages` — that keeps the
# mixins usable unmodified on all three module systems.
{
  options.environment.systemPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    visible = false;
    description = ''
      Compatibility shim for NixOS-shaped modules imported into this
      standalone Home Manager configuration. Contents end up in
      {option}`home.packages`.
    '';
  };

  config.home.packages = config.environment.systemPackages;
}
