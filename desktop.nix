{
  config,
  lib,
  pkgs,
  ...
}:
# Desktop PC specific configuration
{
  # Linux-zen Kernel für maximale Gaming-Performance
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Desktop-spezifische Pakete
  environment.systemPackages = with pkgs; [
    lm_sensors # Hardware sensors (temp, fan speed, etc.)
    # nvtop       # GPU monitoring (falls NVIDIA/AMD GPU)
  ];

  # Performance-optimierte Power Settings
  powerManagement.cpuFreqGovernor = "performance";

  # Kein Power Saving (Desktop hat Strom)
  services.tlp.enable = false;

  # Hardware Sensors
  hardware.sensor.iio.enable = false; # Nur für Laptops/Tablets relevant

  # Bluetooth oft nicht benötigt auf Desktop
  hardware.bluetooth.enable = false;

  # Volle Performance, keine Stromsparmaßnahmen
  boot.kernelParams = [
    "quiet"
    "splash"
    "mitigations=off" # Mehr Performance, weniger Sicherheit
    "split_lock_detect=off"
    "nowatchdog"
  ];

  # CPU Microcode Updates (Intel/AMD)
  hardware.cpu.intel.updateMicrocode = true; # Falls Intel
  # hardware.cpu.amd.updateMicrocode = true;  # Falls AMD (alternativ)

  # GPU-spezifische Einstellungen (optional, je nach Hardware)
  # Für NVIDIA:
  ervices.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # proprietary driver
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  hardware.graphics = {
    extraPackages = with pkgs; [
      libvdpau-va-gl
    ];
  };

  # GameMode mit aggressiven Einstellungen
  programs.gamemode.settings = {
    general = {
      renice = 15;
      desiredgov = "performance";
    };
    gpu = {
      apply_gpu_optimizations = "accept-responsibility";
      gpu_device = 0;
    };
  };

  # Nvidia-spezifische Umgebungsvariablen (wegen Wayland Verwendung)
  environment.variables = {
    # GBM Backend für Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Für bessere Wayland-Performance
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    # Nvidia-spezifisch
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
  };

  # filesystem Optimierungen
  fileSystems."/" = {
    options = lib.mkForce [ "noatime" "nodiratime" ];
  };
  fileSystems."/boot" = {
    options = lib.mkForce [ "noatime" ];
  };
}
