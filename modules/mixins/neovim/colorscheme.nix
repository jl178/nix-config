{ config, pkgs, inputs, ... }: {
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.gruvbox-material ];
    colorscheme = "gruvbox-material";
    extraConfigLua = ''
      vim.cmd "let g:gruvbox_material_background = \'hard\'"
      vim.cmd.colorscheme 'gruvbox-material'
      vim.cmd "let g:lightline = {'colorscheme' : 'gruvbox-material'}"
      local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
      vim.api.nvim_create_autocmd('TextYankPost', {
          callback = function()
            vim.highlight.on_yank()
          end,
          group = highlight_group,
          pattern = '*',
        })
      vim.fn.sign_define("DiagnosticSignError",
        { text = " ", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DiagnosticSignWarn",
        { text = " ", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignInfo",
        { text = " ", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint",
        { text = "󰌵", texthl = "DiagnosticSignHint" })
    '';
  };
}
