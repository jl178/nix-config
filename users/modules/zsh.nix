{ config, pkgs, lib, ... }:

{
  home = { packages = with pkgs; [ zsh ]; };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      bluetooth = "blueman-manager &> /dev/null & disown";
      increase-laptop-resolution =
        ''hyprctl keyword monitor "eDP-1,1920x1200,60,1.5"'';
      decrease-laptop-resolution =
        ''hyprctl keyword monitor "eDP-1,1920x1200,60,1.0"'';
      game = "moonlight &> /dev/null & disown";
      volume = "pavucontrol &> /dev/null & disown";
      fix-screen-tearing = "nvidia-settings --assign CurrentMetaMode=\"nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }\"";
      volume-increase = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
      volume-decrease = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
      web = "brave &> /dev/null & disown";
      screenshot =
        ''grim -g "$(slurp -o)" $HOME/Pictures/$(date +'%s_grim.png')'';
      snip = ''
        grim -g "$(slurp)" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')'';
      n = "nix-shell -p";
      q = "exit";
      ls = "lsd -Fl";
      l = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      t = "tree";
      rm = "rm -v";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      nv = "neovide";
      gs = "git status";
      ga = "git add -A";
      gc = "git commit";
      gpull = "git pull";
      gpush = "git push";
      gd = "git diff * | bat";
      gl = "git log --stat --graph --decorate --oneline";
      b = "bat";
      rr = ''
        ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'';
      diff = "diff --color=auto";
      grep = "grep --color=auto";
      ip = "ip --color=auto";
      nix-rebuild-darwin = ''
        nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake ".#jlittle-mbp" --impure'';
    };

    initExtra = ''
      # Colored pagers
      export LESS='-R --use-color -Dd+r$Du+b'
      export MANPAGER='less -R --use-color -Dd+r -Du+b'

      # Setting Default Editor
      export EDITOR='nvim'
      export VISUAL='nvim'

      # File to store ZSH history
      export HISTFILE=~/.zsh_history

      # Number of commands loaded into memory from HISTFILE
      export HISTSIZE=1000

      # Maximum number of commands stores in HISTFILE
      export SAVEHIST=1000

      # Setting default Ranger RC to false to avoid loading it twice
      export RANGER_LOAD_DEFAULT_RC='false'
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#A9A9A9'

      # Loading ZSH modules
      autoload -Uz compinit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion::complete:*' gain-privileges 1
      zstyle ':completion:*' rehash true
      zstyle ':vcs_info:git:*' formats 'on %F{red} %b%f '

      compinit
      _comp_options+=(globdots)

      # Load Version Control System into Prompt
      autoload -Uz vcs_info
      precmd() { vcs_info }

      # Prompt Appearance
      setopt PROMPT_SUBST
      PROMPT='%B%F{green}[%n%f@%F{green}%m]%f %F{blue} %1~%f%b ''${vcs_info_msg_0_}
      ❯ '
      set -o vi
      export GDK_SCALE=1
      export GDK_DPI_SCALE=1
      export QT_SCALE_FACTOR=1
    '';
  };
}
