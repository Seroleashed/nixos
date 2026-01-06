# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    
    # Modular configuration files
    ./packages.nix
    ./programs.nix
    ./device.nix  # Device type definition
    
    # Device-specific configuration (conditional import)
    # Wird automatisch basierend auf device.nix geladen
  ] ++ (
    # Conditional imports based on device type
    let 
      deviceType = (import ./device.nix { inherit config lib pkgs; }).config.device.type or "desktop";
    in
    lib.optional (deviceType == "vmware") ./vmware.nix ++
    lib.optional (deviceType == "virtualbox") ./virtualbox.nix ++
    lib.optional (deviceType == "laptop") ./laptop.nix ++
    lib.optional (deviceType == "desktop") ./desktop.nix
  );

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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
  programs.dconf.enable = true;  # Benötigt für GTK-Apps
  
  # SDDM Theme (Login-Screen)
  services.displayManager.sddm = {
    theme = "breeze";  # Breeze Dark ist der Standard
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

  # Sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # User account
  users.users.stinooo = {
    isNormalUser = true;
    description = "D L";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  users.defaultUserShell = pkgs.zsh;

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
    experimental-features = [ "nix-command" "flakes" ];
  };

  # sops-nix Secrets Management
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.sshKeyPaths = [ "/home/stinooo/.ssh/sops-key" ];
    
    # Beispiel-Secrets (aktiviere nach Bedarf)
    # secrets = {
    #   wifi_password = {
    #     owner = "root";
    #   };
    #   github_ssh_key = {
    #     owner = "stinooo";
    #     mode = "0600";
    #   };
    # };
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
