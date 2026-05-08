{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
      settings = {
        auto_clean_after_session_restore = true;
        close_if_last_window = true;
        window.position = "left";
        enable_diagnostics = true;
        enable_git_status = true;
      };
    };
    extraConfigLua = ''
      vim.keymap.set('n', '<leader>o', function()
        if vim.bo.filetype == "neo-tree" then
          vim.cmd.wincmd "p"
        else
          vim.cmd.Neotree "focus"
        end
      end
      , { desc = 'Switch to File Explorer' })
    '';
    keymaps = [{
      mode = "n";
      key = "<leader>e";
      action = "<CMD>Neotree toggle<cr>";
      options = { desc = "Toggle File Explorer"; };
    }];
  };
}
