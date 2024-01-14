{
  programs.nixvim.plugins = {
    # lsp-lines.enable = true;
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
    onAttach = ''
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end
      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')
    '';
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
      vim.diagnostic.config({
        virtual_text = {
          prefix = '■', -- You can choose any prefix symbol
          spacing = 4, -- Spacing between the line text and the diagnostic message
        },
        float = {
        },
      })
      require"fidget".setup{
        notification = {
            window = {
              normal_hl = "Normal",
              winblend = 0, -- Value for 'winblend'
              border = "rounded",
            },
        },
      }
    '';
  };
}
