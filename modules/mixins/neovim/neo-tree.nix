{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;
      autoCleanAfterSessionRestore = true;
      closeIfLastWindow = true;
      window = { position = "left"; };
      enableDiagnostics = true;
      enableGitStatus = true;
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
