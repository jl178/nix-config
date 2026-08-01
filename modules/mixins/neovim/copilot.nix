{
  programs.nixvim = {
    # copilot.vim is unfree. Nixvim builds its own nixpkgs instance unless
    # nixpkgs.useGlobalPackages is set, so the host's allowUnfree does not
    # reach it and the plugin fails to evaluate.
    nixpkgs.config.allowUnfree = true;
    plugins.copilot-vim.enable = true;
    extraConfigLua = ''
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<C-A>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
    '';
  };
}
