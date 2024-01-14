{
  programs.nixvim = {
    plugins.copilot-vim.enable = true;
    extraConfigLua = ''
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<C-Tab>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    '';
  };
}
