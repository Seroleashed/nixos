{ config, pkgs, ... }:

{
  # Firefox
  programs.firefox.enable = true;

  # Git - Systemweite Basis-Konfiguration
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      # Weitere Einstellungen können hier hinzugefügt werden
      # oder du konfigurierst Git später per ~/.gitconfig
    };
  };

  # Zsh - Umfangreiche Konfiguration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    
    shellAliases = {
      # System
      ll = "eza -l --icons";
      la = "eza -la --icons";
      ls = "eza --icons";
      tree = "eza --tree --icons";
      
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # NixOS
      update = "sudo nixos-rebuild switch";
      update-nix-config = "sudo nixos-rebuild switch";
      rebuild = "sudo nixos-rebuild switch";
      nix-clean = "sudo nix-collect-garbage -d";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      
      # Docker
      dps = "docker ps";
      dpa = "docker ps -a";
      
      # Andere nützliche Aliases
      cat = "bat";
      grep = "rg";
      find = "fd";
    };
    
    shellInit = ''
      # Disable Ctrl+S (flow control)
      stty -ixon
    '';
    
    interactiveShellInit = ''
      # Bessere History-Suche
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      
      # Zoxide initialisieren (besseres cd)
      eval "$(zoxide init zsh)"
      
      # TheFuck initialisieren mit "okay" Alias
      # "okay" ist sicherer als "yes" (vermeidet Konflikt mit Unix-Befehl)
      eval "$(thefuck --alias okay)"
      
      # FZF Key Bindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      
      # FZF mit bat preview
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always {}' --preview-window=right:60%"
      
      # Bessere Completion
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt ALWAYS_TO_END
      
      # History Optionen
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      
      # Sonstiges
      setopt AUTO_CD
      setopt CORRECT
    '';
    
    promptInit = ''
      # Starship Prompt initialisieren
      eval "$(starship init zsh)"
    '';
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      
      format = "$all";
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      
      git_branch = {
        symbol = " ";
      };
      
      git_status = {
        conflicted = "⚔️ ";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "🤷 ";
        stashed = "📦 ";
        modified = "📝 ";
        staged = "✅ ";
        renamed = "👅 ";
        deleted = "🗑️ ";
      };
      
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
    };
  };

  # Zoxide (besseres cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # FZF (Fuzzy Finder)
  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };

  # Tmux - Basis-Konfiguration
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    
    extraConfig = ''
      # Bessere Prefix-Taste (Ctrl+a statt Ctrl+b)
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix
      
      # Schnelleres Antwortverhalten
      set -s escape-time 0
      
      # Mehr History
      set -g history-limit 50000
      
      # Mouse-Support
      set -g mouse on
      
      # Fenster-Nummern bei 1 starten
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Fenster automatisch umbenennen
      setw -g automatic-rename on
      set -g renumber-windows on
      
      # Bessere Splits (aktuelle Directory beibehalten)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      
      # Vim-ähnliche Pane-Navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Pane-Größe anpassen
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      
      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      
      # Bessere Farben
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };

  # VS Code
  programs.vscode = {
    enable = true;
  };
}
