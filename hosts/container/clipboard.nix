{ config, lib, pkgs, ... }:

# Clipboard and terminal plumbing for the "WezTerm on the Mac, everything else
# in the container" setup.
#
# The container has no X11/Wayland display, so the usual clipboard providers
# (wl-copy, xclip) have nothing to talk to. Instead the whole chain rides on
# OSC 52: neovim writes the escape sequence to its tty, tmux forwards it up,
# and WezTerm turns it into a macOS clipboard write.
#
#   nvim --(OSC 52)--> tmux --(OSC 52)--> WezTerm --> macOS pasteboard
#
# Pasting deliberately does NOT go back through OSC 52. Reading the clipboard
# means querying the terminal and waiting for a reply, which WezTerm only sends
# when `enable_osc52_clipboard_reading` is turned on; without it nvim blocks for
# ten seconds on every paste. Cmd-V is unaffected — that arrives as an ordinary
# bracketed paste, not a clipboard query.
{
  programs.tmux = {
    # Home Manager defaults to "screen", which costs italics, undercurl and
    # 256-colour handling inside nvim.
    terminal = "tmux-256color";

    extraConfig = ''
      # --- OSC 52 clipboard -------------------------------------------------
      # Accept OSC 52 from programs in the pane (nvim) and relay it to WezTerm.
      set -g set-clipboard on
      # tmux only relays if the outer terminal advertises the Ms capability;
      # declare it for every TERM rather than relying on the terminfo entry.
      set -as terminal-features ',*:clipboard'
      # Let programs that wrap escape sequences in DCS reach the terminal too.
      set -g allow-passthrough on

      # Autoread/cursor-shape handoff between WezTerm, tmux and nvim.
      set -g focus-events on
      set -sg escape-time 10
    '';
  };

  programs.nixvim.extraConfigLua = ''
    -- Ship yanks to the macOS clipboard over OSC 52; read pastes back out of
    -- the local register instead of querying the terminal (see clipboard.nix).
    do
      local osc52 = require('vim.ui.clipboard.osc52')
      local function paste()
        return { vim.fn.split(vim.fn.getreg('"'), '\n'), vim.fn.getregtype('"') }
      end
      vim.g.clipboard = {
        name = 'OSC 52',
        copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
        paste = { ['+'] = paste, ['*'] = paste },
      }
    end
  '';
}
