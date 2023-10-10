{ config, pkgs, lib, ... }:

{
  home = { packages = with pkgs; [ zsh ]; };
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      web = "google-chrome-stable &> /dev/null & disown";
      n = "nix-shell -p";
      q = "exit";
      ls = "lsd -Fl";
      l = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      t = "tree";
      rm = "rm -v";
      open = "xdg-open";
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
    '';
  };
}
