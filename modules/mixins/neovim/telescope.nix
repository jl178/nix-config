{ pkgs, lib, ... }:

{
  programs.nixvim.plugins.telescope = {
    enable = true;
    extensions.frecency.enable = true;
    extensions.fzf-native.enable = true;

    extensions.file_browser = {
      enable = true;
      hidden = true;
      depth = 9999999999;
      autoDepth = true;
    };
    keymaps = {
      "<leader>sf" = "find_files";
      "<leader>sg" = "live_grep";
      "<leader>sr" = "resume";
      "gI" = "lsp_implementations";
      "gr" = "lsp_references";
      "<leader><space>" = "buffers";
    };
  };
  # programs.nixvim.keymaps = [
  #   {
  #     mode = "n";
  #     key = "<leader>?";
  #     action = "<CMD>:require('telescope.builtin').oldfiles<cr>";
  #     options = { desc = "[?] Find recently opened files"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader><space>";
  #     action = "<CMD>:require('telescope.builtin').buffers<cr>";
  #     options = { desc = "[ ] Find existing buffers"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>gf";
  #     action = "require('telescope.builtin').git_files";
  #     options = { desc = "Search [G]it [F]iles"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>sf";
  #     action = "require('telescope.builtin').find_files";
  #     options = { desc = "[S]earch [F]iles"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>sh";
  #     action = "require('telescope.builtin').help_tags";
  #     options = { desc = "[S]earch [H]elp"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>sw";
  #     action = "require('telescope.builtin').grep_string";
  #     options = { desc = "[S]earch current [W]ord"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>sg";
  #     action = "require('telescope.builtin').live_grep";
  #     options = { desc = "[S]earch by [G]rep"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>sd";
  #     action = "require('telescope.builtin').diagnostics";
  #     options = { desc = "[S]earch [D]iagnostics"; };
  #   }
  #   {
  #     mode = "n";
  #     key = "<leader>sr";
  #     action = "require('telescope.builtin').resume";
  #     options = { desc = "[S]earch [R]esume"; };
  #   }
  # ];

}
