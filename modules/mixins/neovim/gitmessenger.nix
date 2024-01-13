{
  programs.nixvim = {
    plugins.gitmessenger = {
      enable = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>G";
        action = "<CMD>GitMessenger<cr>";
        options = { desc = "Toggle Git Message"; };
      }
    ];
  };
}
