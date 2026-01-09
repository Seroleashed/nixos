{
  config,
  pkgs,
  ...
}: {
  # Home Manager Basics
  home.username = "stinooo";
  home.homeDirectory = "/home/stinooo";

  # Home Manager Version (muss mit NixOS-Version kompatibel sein)
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User-spezifische Pakete (zusätzlich zu system packages)
  home.packages = with pkgs; [
    # Nix Language Server für VS Code
    nil
    alejandra

    # Gaming-Tools
    gamemode
    gamescope

    # Launcher und Stores
    bottles

    # Utilities
    protonup-qt # Proton-GE Updater
    protontricks # Winetricks für Proton
    steamtinkerlaunch # Advanced Steam launch Options

    # Performance Monitoring
    nvtop
    # htop als system package
    iotop

    # generelle Tools
  ];

  # Firefox
  programs.firefox.enable = true;

  # Steam Konfiguration
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin # Letzte stabile Version aus nixpkgs
    ];
  };

  # Git Configuration (mit gh Integration)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Seroleashed";
        email = "dsilorenz@gmail.com";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      credential.helper = "store";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";
      };
    };
  };

  # Plasma Manager Configuration
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "open";
      lookAndFeel = "org.kde.breezedark.desktop";
    };
    input.keyboard = {
      numlockOnStartup = "on";
    };
    shortcuts = {
      kwin."Window Quick Tile Bottom" = "Meta+Down";
      kwin."Window Quick Tile Bottom Left" = [];
      kwin."Window Quick Tile Bottom Right" = [];
      kwin."Window Quick Tile Left" = "Meta+Left";
      kwin."Window Quick Tile Right" = "Meta+Right";
      kwin."Window Quick Tile Top" = "Meta+Up";
      kwin."Window Quick Tile Top Left" = [];
      kwin."Window Quick Tile Top Right" = [];
    };
    kwin = {
      effects = {
        blur = {
          enable = true;
          noiseStrength = 0;
          strength = 6;
        };
        slideBack.enable = true;
        translucency.enable = true;
        wobblyWindows.enable = true;
      };
    };
    session = {
      general.askForConfirmationOnLogout = false;
      sessionRestore.restoreOpenApplicationsOnLogin = "onLastLogout";
    };
    krunner = {
      position = "center";
    };
    fonts = {
      general = {
        family = "FiraMono";
        pointSize = 11;
      };
    };
    powerdevil = {
      AC = {
        whenLaptopLidClosed = "sleep";
        powerButtonAction = "lockScreen";
        autoSuspend = {
          action = "sleep";
          idleTimeout = 1500;
        };
        powerProfile = "performance";
      };
      battery = {
        whenLaptopLidClosed = "sleep";
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
        powerProfile = "balanced";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
        powerProfile = "powerSaving";
      };
    };
    configFile = {
      kdeglobals."KFileDialog Settings"."Allow Expansion" = false;
      kdeglobals."KFileDialog Settings"."Automatically select filename extension" = true;
      kdeglobals."KFileDialog Settings"."Breadcrumb Navigation" = true;
      kdeglobals."KFileDialog Settings"."Decoration position" = 2;
      kdeglobals."KFileDialog Settings"."Show Full Path" = true;
      kdeglobals."KFileDialog Settings"."Show Inline Previews" = true;
      kdeglobals."KFileDialog Settings"."Show Preview" = false;
      kdeglobals."KFileDialog Settings"."Show Speedbar" = true;
      kdeglobals."KFileDialog Settings"."Show hidden files" = true;
      kdeglobals."KFileDialog Settings"."Sort by" = "Name";
      kdeglobals."KFileDialog Settings"."Sort directories first" = true;
      kdeglobals."KFileDialog Settings"."Sort hidden files last" = false;
      kdeglobals."KFileDialog Settings"."Sort reversed" = false;
      kdeglobals."KFileDialog Settings"."Speedbar Width" = 192;
      kdeglobals."KFileDialog Settings"."View Style" = "DetailTree";
    };
  };

  # GitHub CLI (gh)
  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "https";
      editor = "code --wait";
      prompt = "enabled";
    };

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

    oh-my-zsh = {
      enable = true;

      plugins = ["tmux" "bun" "colorize" "docker" "docker-compose" "dotenv" "emoji" "fzf" "gh" "git" "git-auto-fetch" "git-commit" "gitfast" "golang" "kitty" "pip" "ssh" "starship" "tailscale" "uv" "vi-mode" "virtualenv" "vscode" "zoxide"];
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

    initContent = ''
      # Ensure the plugin is loaded
      plugins=(tmux)

      # Set autostart before sourcing oh-my-zsh
      ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_AUTOCONNECT=true
      ZSH_TMUX_AUTOQUIT=true

      # Source oh-my-zsh
      source $ZSH/oh-my-zsh.sh

      # Disable Ctrl+S (flow control)
      stty -ixon

      # Aliases auch mit sudo verfügbar machen
      alias sudo='sudo '

      # Zoxide initialisieren (besseres cd)
      eval "$(zoxide init zsh)"

      # Starship Prompt
      eval "$(starship init zsh)"

      # pay-respects
      eval "$(pay-respects zsh --alias okay)"

      # navi for command cheatsheets
      eval "$(navi widget zsh)"

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
  };

  programs.kitty.settings = {
    detect_urls = "yes";
    url_style = "curly";
    show_hyperlink_targets = "yes";
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
        truncation_length = 0;
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = " ";
      };

      git_status = {
        conflicted = "⚔️ ";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = " ($count)🤷";
        stashed = " ($count)📦";
        modified = " ($count)📝";
        staged = " [++($count)]✅";
        renamed = " ($count)👅";
        deleted = " ($count) 🗑️";
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

  # Eza (besseres ls)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  # Tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g @catppuccin_status_modules_left 'session'
          set -g @catppuccin_status_modules_right 'directory date_time'
          set -g @catppuccin_window_current_text '#{window_name}'
          set -g @catppuccin_directory_text '#{pane_current_path}'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60'
        '';
      }
    ];

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

      # vorherige Session wiederherstellen
      set -g @continuum-boot 'on'

      set -g status-interval 1
      set-option -g focus-events on
    '';
  };

  # Kitty Terminal Configuration
  programs.kitty = {
    enable = true;

    font = {
      name = "FiraMono Nerd Font";
      size = 12;
    };

    settings = {
      # Theme/Colors
      background = "#1e1e1e";
      foreground = "#d4d4d4";
      background_opacity = "0.95";

      # Window
      window_padding_width = 10;

      # Shell Integration
      shell_integration = "enabled";

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "0.5";

      # Scrollback
      scrollback_lines = 10000;

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };

    keybindings = {
      # Clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      # Font size
      "ctrl+shift+equal" = "increase_font_size";
      "ctrl+minus" = "decrease_font_size";
      "ctrl+0" = "restore_font_size";

      # Tabs
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+tab" = "next_tab";
      "ctrl+shift+tab" = "previous_tab";

      # Windows
      "ctrl+shift+enter" = "new_window";
    };
  };

  # VS Code - Vollständige Entwicklungsumgebung
  programs.vscode = {
    enable = true;

    mutableExtensionsDir = false;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Python
      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy

      # JavaScript/TypeScript
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode

      # Rust
      rust-lang.rust-analyzer

      # Go
      golang.go

      # Nix
      jnoortheen.nix-ide

      # PHP
      bmewburn.vscode-intelephense-client
      #devsense.profiler-php-vscode

      # Git
      #eamodio.gitlens
      #mhutchie.git-graph

      # Remote Development
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers

      # API Testing
      humao.rest-client

      # UI/UX
      pkief.material-icon-theme
      usernamehw.errorlens

      # Utilities
      aaron-bond.better-comments
      christian-kohler.path-intellisense
      editorconfig.editorconfig

      # Claude Code (falls verfügbar)
      # anthropic.claude-code
    ];

    profiles.default.userSettings = {
      # Editor Basics
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'FiraMono Nerd Font', 'Droid Sans Mono', 'monospace'";
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.detectIndentation" = true;
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      "editor.minimap.enabled" = true;
      "editor.rulers" = [80 120];
      "editor.wordWrap" = "on";
      "editor.suggestSelection" = "first";
      "editor.inlineSuggest.enabled" = true;
      "editor.quickSuggestions" = {
        "other" = true;
        "comments" = false;
        "strings" = true;
      };
      "explorer.confirmDelete" = false;

      # Theme & Icons
      "workbench.colorTheme" = "Default Dark Modern";
      "workbench.iconTheme" = "material-icon-theme";

      # Terminal
      "terminal.integrated.fontFamily" = "'FiraMono Nerd Font'";
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "terminal.external.linuxExec" = "kitty";

      # Files
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # Git
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
      "gitlens.advanced.messages"."suppressCommitHasNoPreviousCommitWarning" = true;

      # Python
      "python.defaultInterpreterPath" = "python3";
      "python.linting.enabled" = true;
      "python.linting.pylintEnabled" = false;
      "python.linting.ruffEnabled" = true;
      "python.formatting.provider" = "black";
      "python.languageServer" = "Pylance";
      "python.analysis.typeCheckingMode" = "basic";
      "python.analysis.autoImportCompletions" = true;
      "[python]" = {
        "editor.defaultFormatter" = "ms-python.black-formatter";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };

      # JavaScript/TypeScript
      "javascript.updateImportsOnFileMove.enabled" = "always";
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "eslint.enable" = true;
      "eslint.validate" = ["javascript" "javascriptreact" "typescript" "typescriptreact"];
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[javascriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # Prettier
      "prettier.singleQuote" = true;
      "prettier.trailingComma" = "es5";
      "prettier.semi" = true;

      # Rust
      "rust-analyzer.checkOnSave.command" = "clippy";
      "rust-analyzer.inlayHints.enable" = true;
      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
      };

      # Go
      "go.useLanguageServer" = true;
      "go.toolsManagement.autoUpdate" = true;
      "[go]" = {
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = "explicit";
        };
      };

      # Lua
      "[lua]" = {
        "editor.defaultFormatter" = "sumneko.lua";
      };

      # Nix
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = ["alejandra"];
          };
        };
      };
      "nix.formatterPath" = "alejandra";
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
      };
      # Explizite Datei-Assoziationen
      "files.associations" = {
        "*.nix" = "nix";
        "flake.lock" = "json";
      };

      # PHP
      "php.suggest.basic" = false;
      "php.validate.enable" = false;
      "intelephense.format.enable" = true;
      "[php]" = {
        "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
      };

      # Error Lens
      "errorLens.enabledDiagnosticLevels" = ["error" "warning" "info"];

      # Better Comments
      "better-comments.tags" = [
        {
          "tag" = "!";
          "color" = "#FF2D00";
        }
        {
          "tag" = "?";
          "color" = "#3498DB";
        }
        {
          "tag" = "//";
          "color" = "#474747";
        }
        {
          "tag" = "todo";
          "color" = "#FF8C00";
        }
        {
          "tag" = "*";
          "color" = "#98C379";
        }
      ];

      # Remote Development
      "remote.SSH.remotePlatform" = {
        "localhost" = "linux";
      };

      # Debug
      "debug.console.fontSize" = 13;
      "debug.console.fontFamily" = "'FiraMono Nerd Font'";
    };
  };

  # XDG Base Directories
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Session Variables für konsistenten PATH
  home.sessionVariables = {
    # Stelle sicher dass Home Manager Binaries im PATH sind
    # (wichtig für VS Code vom Application Menu)
  };

  # Expliziter PATH für Programme die nicht von der Shell starten
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
  ];
}
