{
  programs.nixvim = {
    plugins.gitmessenger = {
      enable = true;
      floatingWinOps = { border = "rounded"; };
    };
    keymaps = [{
      mode = "n";
      key = "<leader>G";
      action = "<CMD>GitMessenger<cr>";
      options = { desc = "Toggle Git Message"; };
    }];
  };
}
