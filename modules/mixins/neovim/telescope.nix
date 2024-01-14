{ pkgs, lib, ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;
    extensions.frecency.enable = true;
    extensions.fzf-native.enable = true;
    highlightTheme = "gruvbox-material";

    extensions.file_browser = {
      enable = true;
      hidden = true;
      depth = 9999999999;
      autoDepth = true;
    };
    keymaps = {
      "<leader>sf" = {
        action = "find_files";
        desc = "[S]earch [F]iles";
      };
      "<leader>sg" = {
        action = "live_grep";
        desc = "[S]earch with [G]rep";
      };
      "<leader>sr" = {
        action = "resume";
        desc = "[S]earch [R]esume";
      };
      "gI" = {
        action = "lsp_implementations";
        desc = "[G]o to [I]mplementation";
      };
      "gr" = {
        action = "lsp_references";
        desc = "[G]o to [R]eferences";
      };
      "<leader><space>" = {
        action = "buffers";
        desc = "Show Buffers";
      };
    };
  };
}
