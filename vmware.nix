{ config, lib, pkgs, ... }:

# VMware Workstation/Player specific configuration

{
  # VMware Guest Tools - Dies aktiviert automatisch open-vm-tools
  virtualisation.vmware.guest.enable = true;
  
  # Video Driver
  services.xserver.videoDrivers = [ "vmware" ];
  
  # Open VM Tools explizit installieren (für manuelle Tools)
  environment.systemPackages = with pkgs; [
    open-vm-tools
  ];
  
  # Services für Copy/Paste und Integration
  # Diese werden durch virtualisation.vmware.guest.enable automatisch gestartet,
  # aber wir definieren sie explizit für bessere Kontrolle
  
  systemd.services.vmtoolsd = {
    description = "VMware Tools Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.open-vm-tools}/bin/vmtoolsd";
      Restart = "always";
      TimeoutStopSec = "5";
    };
  };

  # User-Service für Copy/Paste in grafischer Umgebung (wichtig!)
  # Besonders wichtig für Wayland/Plasma
  systemd.user.services.vmware-user = {
    description = "VMware User Agent for Copy/Paste";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.open-vm-tools}/bin/vmware-user";
      Restart = "always";
      RestartSec = "2";
    };
  };
  
  # VMCI (Virtual Machine Communication Interface) für bessere Integration
  boot.kernelModules = [ "vmw_vsock_vmci_transport" "vmw_vmci" "vmwgfx" ];
  
  # Shared Folders Support (optional, auskommentiert)
  # Aktiviere dies wenn du Shared Folders zwischen Host und Guest nutzen möchtest:
  # 
  # boot.kernelModules = [ "vmhgfs" ];
  # 
  # systemd.mounts = [{
  #   what = ".host:/";
  #   where = "/mnt/hgfs";
  #   type = "fuse.vmhgfs-fuse";
  #   options = "allow_other,auto_unmount";
  # }];
  # 
  # systemd.automounts = [{
  #   where = "/mnt/hgfs";
  #   wantedBy = [ "multi-user.target" ];
  # }];
}
