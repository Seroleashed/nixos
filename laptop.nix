{ config, lib, pkgs, ... }:

# Laptop-specific configuration

{
  # Laptop-spezifische Pakete
  environment.systemPackages = with pkgs; [
    powertop      # Power management tool
    acpi          # Battery/AC adapter info
    brightnessctl # Screen brightness control
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
}
