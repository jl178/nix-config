{
  programs.nixvim.plugins = {
    # lsp-lines.enable = true;
    lsp-format.enable = true;
    lspkind.enable = true;
    fidget.enable = true;
    # java.enable = true;
  };
  programs.nixvim.plugins.lsp = {
    enable = true;
    # Work around neovim/neovim#33224: incremental sync's cached buffer snapshot
    # can desync from the real buffer, after which the next keystroke throws
    # "attempt to get length of local 'prev_line'" out of vim/lsp/sync.lua.
    # Full sync never calls compute_diff, so the crash cannot happen.
    #
    # This wraps vim.lsp.start rather than setting vim.lsp.config("*"), because
    # the "*" defaults only reach servers resolved through vim.lsp.enable.
    # copilot.vim calls vim.lsp.start directly and would otherwise stay on
    # incremental sync. Drop this once #33224 is fixed.
    preConfig = ''
      local __lsp_start = vim.lsp.start
      vim.lsp.start = function(config, opts)
        config = vim.tbl_deep_extend("force", config or {}, {
          flags = { allow_incremental_sync = false },
        })
        return __lsp_start(config, opts)
      end
    '';
    keymaps.lspBuf = { "<leader>fm" = "format"; };
    servers.nixd.enable = true;
    servers.cssls.enable = true;
    servers.clangd.enable = true;
    servers.cmake.enable = true;
    servers.dockerls.enable = true;
    servers.gopls.enable = true;
    servers.jdtls.enable = true;
    servers.jdtls.settings = {
      root_dir = {
        __raw = ''
          require("lspconfig").util.root_pattern(
          		".git",
          		"mvnw",
          		"gradlew",
          		"pom.xml",
          		"build.gradle",
          		"build.gradle.kts"
          	)(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))'';
      };
    };
    # servers.java_language_server.enable = true;
    # servers.jsonls.enable = true;
    servers.lua_ls.enable = true;
    servers.pyright.enable = true;
    servers.ts_ls.enable = true;
    servers.yamlls.enable = true;
    servers.terraformls.enable = true;
    servers.tailwindcss.enable = true;
    servers.bashls.enable = true;
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
