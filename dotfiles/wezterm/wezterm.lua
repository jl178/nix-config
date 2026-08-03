-- Raw copy of what users/modules/wezterm.nix generates, for machines where Nix
-- is not available. Copy this file to ~/.config/wezterm/wezterm.lua and the
-- colors/ directory next to it to ~/.config/wezterm/colors/.
--
-- `./dev wezterm` from the repo root does that for you.
--
-- Requires the JetBrains Mono font, which Nix would otherwise install:
--   brew install --cask font-jetbrains-mono
-- See https://wezfurlong.org/wezterm/

local wezterm = require 'wezterm'
local config = {}
local act = wezterm.action
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end
-- This is where you actually apply your config choices
-- For example, changing the color scheme:
-- config.color_scheme = 'GruvboxDarkHard'
config.color_scheme = "gruvbox_material_dark_hard"

-- config.default_cursor_style = 'SteadyUnderline'
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.front_end = "WebGpu"

-- Use macOS's own fullscreen (separate Space, standard animation)
-- instead of wezterm's instant undecorated fill. Ignored off macOS.
config.native_macos_fullscreen_mode = true

config.font = wezterm.font("JetBrains Mono Bold")
config.font_rules = {
  {
    italic = false,
    intensity = "Half",
    font = wezterm.font("JetBrains Mono Medium"),
  },
  {
    italic = true,
    intensity = "Half",
    font = wezterm.font("JetBrains Mono Italic"),
  },
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font("JetBrains Mono Bold"),
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font("JetBrains Mono Bold Italic"),
  },
}
config.font_size = 16.0
config.keys = {
  { key = "l", mods = "ALT",        action = wezterm.action.ShowLauncher },
  { key = '{', mods = 'ALT',        action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'ALT',        action = act.ActivateTabRelative(1) },
  { key = "r", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" },
  -- window_decorations = "RESIZE" drops the titlebar, and with it the
  -- green zoom button, so bind macOS's own Ctrl-Cmd-F ourselves.
  { key = "f", mods = "CMD|CTRL",   action = act.ToggleFullScreen },
}
config.window_background_opacity = .95
config.window_padding = {
  left = 1,
  right = 1,
  top = 1,
  bottom = 1,
}

-- Default program
-- config.default_prog = { "powershell.exe", "ubuntu", "-c", "zsh" }
-- config.default_prog = { "/bin/zsh" }
config.launch_menu = {
  {
    label = "Windows: WSL (Ubuntu ZSH)",
    args = { "powershell.exe", "ubuntu", "-c", "zsh" }
  },
  {
    label = "Windows: Dev Container (Archlinux)",
    args = { "ubuntu", "-c", "zsh", "cd $HOME/dev-containers && make run" }
  },
  {
    label = "OSX: ZSH",
    args = { "/bin/zsh" }
  },
  {
    label = "OSX: Dev Container (Archlinux)",
    args = { "/bin/zsh", "cd $HOME/dev-containers/ && make run" }
  },
  -- Nix dev container from this repo: builds/starts it if needed, then drops
  -- into tmux inside it. `dev` is the alias ./dev installs into ~/.zshrc.
  {
    label = "OSX: Nix Dev Container",
    args = { "/bin/zsh", "-lc", "dev tmux" }
  }
}
return config
