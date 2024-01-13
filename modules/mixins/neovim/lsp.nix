{
  programs.nixvim.plugins = {
    lsp-lines.enable = true;
    lsp-format.enable = true;
    lspkind.enable = true;
    fidget.enable = true;
  };
  programs.nixvim.plugins.lsp = {
    enable = true;
    keymaps.lspBuf = { "<leader>fm" = "format"; };
    servers.nixd.enable = true;
    servers.cssls.enable = true;
    servers.java-language-server.enable = true;
    servers.jsonls.enable = true;
    servers.lua-ls.enable = true;
    servers.pyright.enable = true;
    servers.tsserver.enable = true;
    servers.yamlls.enable = true;
  };
  programs.nixvim = {
    extraConfigLua = ''
      local _border = "rounded"
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = _border
        }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = _border
        }
      )
      vim.diagnostic.config{
        float={border=_border}
      }
    '';

  };
}
