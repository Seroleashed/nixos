{
  config,
  lib,
  pkgs,
  ...
}:
# Laptop-specific configuration
{
  # Linux-zen Kernel für Gaming
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Laptop-spezifische Pakete
  environment.systemPackages = with pkgs; [
    powertop # Power management tool
    acpi # Battery/AC adapter info
    brightnessctl # Screen brightness control
  ];

  boot.kernelParams = [
    "quit"
    "spash"
    "split_lock_detect=off"
  ];

  # Power Management
  services.tlp = {
    enable = true;
    settings = {
      # CPU Settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU Boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform Profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Battery thresholds (falls unterstützt)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Suspend/Hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3600
  '';

  # Intel GPU Unterstüzung
  services.xserver.videoDrivers = ["intel"];

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older)
      libvdpau-va-gl
      intel-compute-runtime # OpenCL
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHd"; # für Intel Irix Xe MAX
  };

  # CPU-Governor für Laptop (performance beim Gaming, ondemand normal)
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # GameMode überschreibt zu performance beim Gaming
  programs.gamemode.settings.general = {
    renice = 10;
    desiredgov = "performance";
    igpu_desiredgov = "performance";
  };

  # Thermald für Intel
  services.thermald.enable = true;

  services.power-profiles-daemon.enable = true;

  # Touchpad
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };

  # Backlight control (ohne sudo)
  programs.light.enable = true;

  # Bluetooth (oft auf Laptops gewünscht)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # Bluetooth standardmäßig aus (Akku sparen)
  };
  services.blueman.enable = true;

  # Automatische Helligkeitsanpassung
  services.clight = {
    enable = false; # Optional, kann aktiviert werden
  };

  # WLAN Power Saving
  networking.networkmanager.wifi.powersave = true;

  # filesystem Optimierungen
  fileSystem."/" = {
    options = lib.mkForce ["noatime" "nodiratime"];
  };
  fileSystems."/boot" = lib.mkIf (builtins.hasAttr "/boot" config.fileSystems) {
    options = lib.mkForce ["noatime"];
  };
}
