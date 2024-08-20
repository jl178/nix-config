{
  programs.nixvim = {
    plugins.comment.enable = true;
    keymaps = [
      {
        mode = "n";
        key = "<leader>/";
        action =
          "<esc><cmd>lua require('Comment.api').toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1)<cr>";
        options = { desc = "Toggle comment line"; };
      }
      {
        mode = "v";
        key = "<leader>/";
        action =
          "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>";
        options = { desc = "Toggle comment line for selection"; };
      }

    ];
  };
}
