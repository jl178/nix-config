{
  programs.nixvim = {
    plugins.gitmessenger = {
      enable = true;
      settings.floating_win_ops = { border = "rounded"; };
    };
    keymaps = [{
      mode = "n";
      key = "<leader>G";
      action = "<CMD>GitMessenger<cr>";
      options = { desc = "Toggle Git Message"; };
    }];
  };
}
