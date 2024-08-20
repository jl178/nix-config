{ pkgs, lib, ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;
    extensions.frecency.enable = true;
    extensions.fzf-native.enable = true;
    highlightTheme = "gruvbox-material";

    extensions.file-browser.settings = {
      enable = true;
      hidden = true;
      depth = 9999999999;
      autoDepth = true;
    };
    keymaps = {
      "<leader>sf" = {
        action = "find_files";
        options = { desc = "[S]earch [F]iles"; };
      };
      "<leader>sg" = {
        action = "live_grep";
        options = { desc = "[S]earch with [G]rep"; };
      };
      "<leader>sr" = {
        action = "resume";
        options = { desc = "[S]earch [R]esume"; };
      };
      "gI" = {
        action = "lsp_implementations";
        options = { desc = "[G]o to [I]mplementation"; };
      };
      "gr" = {
        action = "lsp_references";
        options = { desc = "[G]o to [R]eferences"; };
      };
      "<leader><space>" = {
        action = "buffers";
        options = { desc = "Show Buffers"; };
      };
    };
  };
}
