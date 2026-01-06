{ config, pkgs, ... }:

{
  # Home Manager Basics
  home.username = "stinooo";
  home.homeDirectory = "/home/stinooo";
  
  # Home Manager Version (muss mit NixOS-Version kompatibel sein)
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User-spezifische Pakete (zusätzlich zu system packages)
  home.packages = with pkgs; [
    # Wird später erweitert falls nötig
  ];

  # Git Configuration (mit gh Integration)
  programs.git = {
    enable = true;
    userName = "Dein Name";  # ANPASSEN!
    userEmail = "deine@email.de";  # ANPASSEN!
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      credential.helper = "store";  # Optional: Speichert Credentials
    };
    
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
    };
  };

  # GitHub CLI (gh)
  programs.gh = {
    enable = true;
    
    settings = {
      # Git protocol
      git_protocol = "https";
      
      # Editor für gh
      editor = "nano";  # Oder "vim", "code", etc.
      
      # Prompt für Git credentials
      prompt = "enabled";
    };
    
    # Extensions (optional)
    extensions = with pkgs; [
      # gh-dash  # GitHub Dashboard
    ];
  };

  # Bash (als Fallback)
  programs.bash = {
    enable = true;
    shellAliases = config.programs.zsh.shellAliases or {};
  };

  # Zsh (Home Manager übernimmt die Konfiguration)
  programs.zsh = {
    enable = true;
    
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    
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
      update = "sudo nixos-rebuild switch --flake /etc/nixos";
      update-nix-config = "sudo nixos-rebuild switch --flake /etc/nixos";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      nix-clean = "sudo nix-collect-garbage -d";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      
      # GitHub CLI shortcuts
      ghpr = "gh pr list";
      ghprc = "gh pr create";
      ghprs = "gh pr status";
      ghi = "gh issue list";
      ghic = "gh issue create";
      
      # Docker
      dps = "docker ps";
      dpa = "docker ps -a";
      
      # Andere nützliche Aliases
      cat = "bat";
      grep = "rg";
      find = "fd";
    };
    
    initExtra = ''
      # Disable Ctrl+S (flow control)
      stty -ixon
      
      # Zoxide initialisieren (besseres cd)
      eval "$(zoxide init zsh)"
      
      # TheFuck initialisieren mit "okay" Alias
      eval "$(thefuck --alias okay)"
      
      # Starship Prompt
      eval "$(starship init zsh)"
    '';
    
    # Zsh Optionen
    oh-my-zsh = {
      enable = false;  # Wir nutzen eigene Config
    };
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

  # FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--preview 'bat --style=numbers --color=always {}'"
      "--preview-window=right:60%"
    ];
  };

  # Zoxide (besseres cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bat (besseres cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # Eza (besseres ls) - Konfiguration
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = true;
  };

  # Tmux
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

  # Ghostty Terminal Configuration
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = FiraMono Nerd Font
    font-size = 12

    # Theme
    theme = dark
    background-opacity = 0.95

    # Window
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = true

    # Shell
    shell-integration = true
    shell-integration-features = cursor,sudo,title

    # Cursor
    cursor-style = block
    cursor-style-blink = true

    # Scrollback
    scrollback-limit = 10000

    # Performance
    resize-overlay = never

    # Keybindings
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard
    keybind = ctrl+shift+plus=increase_font_size
    keybind = ctrl+minus=decrease_font_size
    keybind = ctrl+0=reset_font_size
    keybind = ctrl+shift+t=new_tab
    keybind = ctrl+shift+w=close_surface
    keybind = ctrl+tab=next_tab
    keybind = ctrl+shift+tab=previous_tab
  '';

  # VS Code Settings (optional)
  programs.vscode = {
    enable = true;
    
    userSettings = {
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'FiraMono Nerd Font', 'Droid Sans Mono', 'monospace'";
      "workbench.colorTheme" = "Default Dark Modern";
      "terminal.integrated.fontFamily" = "'FiraMono Nerd Font'";
      "editor.formatOnSave" = true;
      "files.autoSave" = "afterDelay";
    };
    
    extensions = with pkgs.vscode-extensions; [
      # Beispiel-Extensions (kannst du erweitern)
      # vscodevim.vim
      # ms-python.python
      # rust-lang.rust-analyzer
    ];
  };

  # XDG Base Directories
  xdg = {
    enable = true;
    
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
