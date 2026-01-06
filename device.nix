{ config, lib, pkgs, ... }:

# Device Type Configuration
# Setze hier den Gerätetyp für diese Installation
# Mögliche Werte: "vmware", "virtualbox", "laptop", "desktop"

let
  deviceType = "vmware";  # <-- HIER ÄNDERN JE NACH GERÄT
in
{
  # Diese Variable wird von anderen Modulen verwendet
  options.device = {
    type = lib.mkOption {
      type = lib.types.enum [ "vmware" "virtualbox" "laptop" "desktop" ];
      default = deviceType;
      description = "Type of device this configuration is for";
    };
  };

  config.device.type = deviceType;
}
