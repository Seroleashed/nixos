# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Modular configuration files
      ./packages.nix
      ./device.nix # Device type definition

      # Device-specific configuration (conditional import)
      # Wird automatisch basierend auf device.nix geladen
    ]
    ++ (
      # Conditional imports based on device type
      let
        deviceType = (import ./device.nix {inherit config lib pkgs;}).config.device.type or "desktop";
      in
        lib.optional (deviceType == "vmware") ./vmware.nix
        ++ lib.optional (deviceType == "virtualbox") ./virtualbox.nix
        ++ lib.optional (deviceType == "laptop") ./laptop.nix
        ++ lib.optional (deviceType == "desktop") ./desktop.nix
    );

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  boot.kernel.sysctl = {
    # Memory Management für Gaming
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;

    # Netzwerk-Optimierungen (TCP BBR)
    "net.core.default-qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # File Descriptors für viele gleichzeitige Verbindungen
    "fs.file-max" = 2097152;
  };

  # Kernel Module für Netzwerk-Optimierung
  boot.kernelModules = ["tcp_nnr"];

  # OpenGL/Vulkan Support
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # für 32 bit Spiele
  };

  # GameMode
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };

  # Pipewire mit low-latency für verzögerungs"freie" Audiowiedergabe
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # low-latency Konfiguration
    extraConfig.pipewire = {
      "10-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 256;
        };
      };
    };
  };

  # EarlyOOM Protection (generell)
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 27015;
        to = 27030;
      } # Steam
      {
        from = 27036;
        to = 27037;
      } # Steam Remote Play
    ];
    allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27031;
      } # Steam
      {
        from = 27036;
        to = 27037;
      } # Steam Remote Play
    ];
  };

  # Localization
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Display Manager and Desktop Environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Wayland-spezifische Einstellungen
  services.displayManager.defaultSession = "plasma";

  # KDE/Plasma Systemeinstellungen
  programs.dconf.enable = true; # Benötigt für GTK-Apps

  # SDDM Theme (Login-Screen)
  services.displayManager.sddm = {
    theme = "sddm-sugar-dark"; # Breeze Dark ist der Standard
    # Weitere Theme-Optionen möglich
  };

  # X11 ist für Plasma 6 Wayland nicht nötig, aber einige Anwendungen brauchen XWayland
  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "";
    };
  };

  # Console keymap
  console.keyMap = "de";

  # Printing
  services.printing.enable = true;

  # User account
  users.users.stinooo = {
    isNormalUser = true;
    description = "D L";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix-Einstellungen für schnellere Rebuilds
  nix.settings = {
    # Binary Caches - lädt vorkompilierte Pakete herunter statt selbst zu bauen
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Paralleles Bauen aktivieren (nutzt alle CPU-Kerne)
    max-jobs = "auto";
    cores = 0; # 0 = nutze alle verfügbaren Kerne

    # Automatische Optimierung des Nix Stores (spart Speicherplatz durch Hardlinks)
    auto-optimise-store = true;

    # Experimentelle Features (WICHTIG für Flakes und Home Manager!)
    experimental-features = ["nix-command" "flakes"];
  };

  # Automatische Garbage Collection (löscht alte Generationen)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Tailscale
  services.tailscale.enable = true;

  # Bildschirmschoner/Sperrbildschirm deaktivieren
  services.displayManager.sddm.autoNumlock = true;

  # Für KDE Plasma: Power Management Settings werden über systemsettings5 konfiguriert,
  # aber wir können Screen Locking global deaktivieren
  programs.kde-pim.enable = false;

  environment.systemPackages = with pkgs; [
    sddm-sugar-dark
    kdePackages.qtsvg
    kdePackages.qtmultimedia
    lutris
    wine
    winetricks
    gamemode
    mangohud
    goverlay
  ];

  # Umgebungsvariablen für bessere Wayland-Kompatibilität
  environment.sessionVariables = {
    # Wayland
    NIXOS_OZONE_WL = "1"; # Für Electron-Apps (VS Code, etc.)
    MOZ_ENABLE_WAYLAND = "1"; # Firefox

    # Terminal
    TERM = "xterm-256color";
  };

  # System state version
  system.stateVersion = "25.11";
}
