{ config, pkgs, inputs, ... }: {
  imports = [
    ./neovim/neo-tree.nix
    ./neovim/lsp.nix
    # ./neovim/bufferline.nix
    ./neovim/autopairs.nix
    ./neovim/nvim-cmp.nix
    ./neovim/comment.nix
    ./neovim/telescope.nix
    ./neovim/colorscheme.nix
    ./neovim/indent-blankline.nix
    ./neovim/gitblame.nix
    ./neovim/gitmessenger.nix
    ./neovim/gitsigns.nix
    ./neovim/lualine.nix
    ./neovim/treesitter.nix
    ./neovim/none-ls.nix
    ./neovim/which-key.nix
    ./neovim/copilot.nix
    ./neovim/notify.nix
  ];
  programs.nixvim = {
    #   colorschemes.gruvbox = {
    #     enable = true;
    #     contrastDark = "hard";
    #   };
    enable = true;
    globals.mapleader = " ";
    options = {
      foldlevel = 999;
      number = true;
      relativenumber = true;
      mouse = "a";
      hlsearch = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      updatetime = 250;
      timeoutlen = 300;
      completeopt = "menuone,noselect";
      termguicolors = true;
      expandtab = true;
      smartindent = true;
      tabstop = 4;
      shiftwidth = 4;
    };
    clipboard.register = "unnamedplus";
    viAlias = true;
    vimAlias = true;
    plugins.trouble.enable = true;
    keymaps = [
      {
        mode = "v";
        key = "(";
        action = "<Esc>`>a)<Esc>`<i(<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "[";
        action = "<Esc>`>a]<Esc>`<i[<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "{";
        action = "<Esc>`>a}<Esc>`<i{<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "'";
        action = "<Esc>`>a'<Esc>`<i'<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = ''"'';
        action = ''<Esc>`>a"<Esc>`<i"<Esc>'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "<Tab>";
        action = ">gv";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "<S-Tab>";
        action = "<gv";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "i";
        key = "jj";
        action = "<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" ];
        key = "<Space>";
        action = "<Nop>";
        options = { silent = true; };
      }
      {
        mode = "n";
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "[d";
        action = "vim.diagnostic.goto_prev";
        options = { desc = "Go to previous diagnostic message"; };
      }
      {
        mode = "n";
        key = "]d";
        action = "vim.diagnostic.goto_next";
        options = { desc = "Go to next diagnostic message"; };
      }
      {
        mode = "n";
        key = "<leader>df";
        action = "vim.diagnostic.open_float";
        options = { desc = "Open [D]iagnostic [F]loating message"; };
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "vim.diagnostic.setloclist";
        options = { desc = "Open diagnostics list"; };
      }
    ];
  };
}
