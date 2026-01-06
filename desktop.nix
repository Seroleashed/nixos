{ config, lib, pkgs, ... }:

# Desktop PC specific configuration

{
  # Desktop-spezifische Pakete
  environment.systemPackages = with pkgs; [
    lm_sensors    # Hardware sensors (temp, fan speed, etc.)
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
    "cpufreq.default_governor=performance"
  ];
  
  # CPU Microcode Updates (Intel/AMD)
  hardware.cpu.intel.updateMicrocode = true;  # Falls Intel
  # hardware.cpu.amd.updateMicrocode = true;  # Falls AMD (alternativ)
  
  # GPU-spezifische Einstellungen (optional, je nach Hardware)
  # Für NVIDIA:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   open = false; # proprietary driver
  # };
  
  # Für AMD:
  # services.xserver.videoDrivers = [ "amdgpu" ];
  # hardware.amdgpu.opencl.enable = true;
}
