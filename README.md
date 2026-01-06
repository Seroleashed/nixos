# NixOS Configuration

Meine persönliche NixOS-Konfiguration mit Home Manager, sops-nix und Device-Type-System.

## Features

- ✅ **Flakes-basiert** - Moderne NixOS-Konfiguration
- ✅ **Home Manager** - User-Konfiguration (Git, Zsh, etc.)
- ✅ **sops-nix** - Verschlüsselte Secrets im Repository
- ✅ **Device-Types** - Unterstützung für VMware, VirtualBox, Laptop, Desktop
- ✅ **Modular** - Klare Trennung in einzelne Module

## Struktur

```
.
├── flake.nix                  # Flake Definition
├── configuration.nix          # System-Konfiguration
├── home.nix                   # Home Manager Config
├── packages.nix               # System-Pakete
├── programs.nix               # Programme
├── device.nix                 # Device-Type
├── vmware.nix                 # VMware-spezifisch
├── virtualbox.nix             # VirtualBox-spezifisch
├── laptop.nix                 # Laptop-spezifisch
├── desktop.nix                # Desktop-spezifisch
├── .sops.yaml                 # sops Konfiguration
├── secrets/                   # Verschlüsselte Secrets
│   └── secrets.yaml           # (mit sops verschlüsselt)
└── bootstrap-install.sh       # Auto-Installation
```

## Installation auf neuem Gerät

### Voraussetzungen
- Frische NixOS-Installation mit KDE Plasma

### Schnell-Installation

```bash
# Terminal öffnen
curl -L https://raw.githubusercontent.com/USERNAME/REPO/main/bootstrap-install.sh -o bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

Das Script fragt nach:
- GitHub Username und Repository
- Device-Type (VMware/VirtualBox/Laptop/Desktop)
- Git Name und Email

### Manuelle Installation

```bash
# Repository klonen
git clone https://github.com/USERNAME/REPO.git /tmp/nixos-config

# Hardware-Config sichern
sudo cp /etc/nixos/hardware-configuration.nix /tmp/hw-backup.nix

# Dateien kopieren
sudo cp /tmp/nixos-config/*.nix /etc/nixos/
sudo cp /tmp/nixos-config/.sops.yaml /etc/nixos/

# Hardware-Config wiederherstellen
sudo cp /tmp/hw-backup.nix /etc/nixos/hardware-configuration.nix

# Device-Type setzen
sudo nano /etc/nixos/device.nix

# sops-key erstellen
ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N ""

# Git initialisieren
cd /etc/nixos
sudo git init
sudo git add .
sudo git commit -m "Initial"

# System bauen
sudo nixos-rebuild switch --flake /etc/nixos#vmware
```

## Secrets Management mit sops-nix

### Ersten Secret erstellen

```bash
# sops-key erstellen
ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N ""

# Public Key zu .sops.yaml hinzufügen
cat ~/.ssh/sops-key.pub
# → In .sops.yaml unter 'keys' eintragen

# Secret-Datei erstellen
mkdir -p secrets
sops secrets/secrets.yaml
```

### Secrets bearbeiten

```bash
sops secrets/secrets.yaml
```

### Neues Gerät hinzufügen

```bash
# Auf neuem Gerät: sops-key erstellen und Public Key notieren
ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N ""
cat ~/.ssh/sops-key.pub

# Auf bestehendem Gerät: Key zu .sops.yaml hinzufügen
nano .sops.yaml  # Key hinzufügen

# Secrets neu verschlüsseln
sops updatekeys secrets/secrets.yaml

# Committen
git add .sops.yaml secrets/
git commit -m "Add new device key"
git push
```

## System aktualisieren

```bash
cd /etc/nixos
sudo git pull
sudo nixos-rebuild switch --flake /etc/nixos#vmware
```

## Änderungen pushen

```bash
cd /etc/nixos
sudo nano home.nix  # Änderungen vornehmen
sudo nixos-rebuild switch --flake /etc/nixos#vmware
sudo git add .
sudo git commit -m "Update configuration"
sudo git push
```

## Device-Types

- **vmware**: VMware Workstation/Player (open-vm-tools, Copy/Paste)
- **virtualbox**: VirtualBox (Guest Additions)
- **laptop**: Laptop (TLP, Touchpad, Bluetooth, Power Management)
- **desktop**: Desktop PC (Performance-optimiert, kein Power Saving)

## Anpassungen

### Eigenen Namen/Email setzen

Bearbeite `home.nix`:
```nix
programs.git = {
  userName = "Dein Name";
  userEmail = "deine@email.de";
};
```

### Pakete hinzufügen

Bearbeite `packages.nix` oder `home.nix`:
```nix
environment.systemPackages = with pkgs; [
  neovim
  htop
];
```

### Device-Type ändern

Bearbeite `device.nix`:
```nix
deviceType = "laptop";  # oder vmware, virtualbox, desktop
```

## Lizenz

Diese Konfiguration kann frei verwendet und angepasst werden.
