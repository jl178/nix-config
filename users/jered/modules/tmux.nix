{ config, pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      tmux
      zsh
    ];
  };
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
    ];
    historyLimit = 100000;

    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on

      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Vim style pane selection
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # Shift Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      accent_color="#a9b665"
      bg1="#504945"
      fg1="#32302f"
      bg2="#262626"
      fg2="#ddc7a1"
      orange="#e78a4e"
      bg_light="#A89984"

      # Colors
      set -g status-style "bg=default fg=''${fg2}"
      setw -g window-status-current-style fg=''${fg1},bg=''${accent_color}
      set-option -g status-left-style fg=gray

      set -g window-status-format "#[fg=''${bg1},bg=''${fg1}]#[bold]#[bg=''${bg1},fg=''${fg2}]#I#[fg=''${bg1},bg=''${fg1}]#[nobold]#[bg=''${fg1},fg=''${fg2}] #W  "
      set -g window-status-current-format "#[bg=''${fg1},fg=''${accent_color}]#[bold]#[bg=''${accent_color},fg=''${bg2}]#I#[bg=''${fg1},fg=''${accent_color}]#[nobold]#[bg=''${fg1},fg=''${accent_color}] #W  "
      set -g status-left "#[fg=''${bg1}]#[bold]#[bg=''${bg1},fg=''${accent_color}] #S #[fg=''${bg1},bg=''${fg1}] "
      set -g status-right "#[bg=default,fg=''${bg1}]#[bold]#[bg=''${bg1},fg=''${fg2}] %I:%M %p #[fg=''${bg1},bg=default]"
      set-window-option -g mode-style "bg=''${accent_color} fg=''${bg2}"
      set-option -g status-justify left
      set-option -g status-left-length 100
      set-option -g status-right-length 150

      set-option -g status-keys vi

      # Pane styling
      set -g pane-border-style fg=#5a524c,bg=default
      set -g pane-active-border-style fg="''${accent_color}",bg=default

      set -g window-style 'bg=default'
      set -g window-active-style 'bg=default'

      set-window-option -g mode-keys vi
      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind N split-window -v -c "#{pane_current_path}"
      bind n split-window -h -c "#{pane_current_path}"

      bind -n C-k resize-pane -U 5
      bind -n C-j resize-pane -D 5
      bind -n C-h resize-pane -L 5
      bind -n C-l resize-pane -R 5
    '';
  };
}
