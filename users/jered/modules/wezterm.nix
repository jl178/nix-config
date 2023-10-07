{ config, pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      jetbrains-mono
      wezterm
    ];
  };
  programs.wezterm = {
    enable = true;

    colorSchemes = {
      gruvbox_material_dark_hard = {
        foreground = "#D4BE98";
        background = "#1D2021";
        cursor_bg = "#D4BE98";
        cursor_border = "#D4BE98";
        cursor_fg = "#1D2021";
        selection_bg = "#D4BE98";
        selection_fg = "#3C3836";

        ansi = [ "#1d2021" "#ea6962" "#a9b665" "#d8a657" "#7daea3" "#d3869b" "#89b482" "#d4be98" ];
        brights = [ "#eddeb5" "#ea6962" "#a9b665" "#d8a657" "#7daea3" "#d3869b" "#89b482" "#d4be98" ];
      };
    };

    extraConfig = ''
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
      config.font_size = 12.0
      config.keys = {
        { key = "l", mods = "ALT",        action = wezterm.action.ShowLauncher },
        { key = '{', mods = 'ALT',        action = act.ActivateTabRelative(-1) },
        { key = '}', mods = 'ALT',        action = act.ActivateTabRelative(1) },
        { key = "r", mods = "CTRL|SHIFT", action = "DisableDefaultAssignment" },
      }
      config.window_background_opacity = .75
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
        }
      }
      return config
    '';
  };
}
