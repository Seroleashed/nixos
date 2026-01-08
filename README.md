# NixOS Configuration

Meine persönliche NixOS-Konfiguration mit Home Manager, sops-nix und Device-Type-System.

## Features

- ✅ **Flakes-basiert** - Moderne NixOS-Konfiguration
- ✅ **Home Manager** - User-Konfiguration (Git, Zsh, etc.)
- ✅ **sops-nix** - Verschlüsselte Secrets im Repository, um direkt alle Passwörter, etc. verfügbar zu haben
- ✅ **Device-Types** - Unterstützung für VMware, Raspberry Pi 4 (TODO), Laptop, Desktop
- ✅ **Modular** - Klare Trennung in einzelne Module

## Struktur

```
.
├── flake.nix                  # Flake Definition
├── configuration.nix          # System-Konfiguration
├── home.nix                   # Home Manager Config inkl. Programmen
├── packages.nix               # System-Pakete
├── device.nix                 # Device-Type
├── vmware.nix                 # VMware-spezifisch
├── laptop.nix                 # Laptop-spezifisch
├── desktop.nix                # Desktop-spezifisch
├── .sops.yaml                 # sops Konfiguration
├── secrets/                   # Verschlüsselte Secrets
│   └── secrets.yaml           # (mit sops verschlüsselt)
└── install.sh                 # Auto-Installation
```

## Installation auf neuem Gerät

### Voraussetzungen
- Frische NixOS-Installation

### Schnell-Installation

```bash
# Terminal öffnen
curl -L https://raw.githubusercontent.com/Seroleashed/nixos/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

Das Script fragt nach:
- Device-Type (VMware/VirtualBox/Laptop/Desktop)
- Git User Name und Email

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

### Secrets speichern
#### 1. Füge Secrets in die ./secrets/secrets.yaml ein:
```yaml
wifi_password: mein-passwort
github_token: ghp_xxxxx
```

#### 2. In configuration.nix nutzen
```nix
sops = {
  defaultSopsFile = ./secrets/secrets.yaml;
  age.sshKeyPaths = [ "/home/stinooo/.ssh/sops-key" ];

  secrets.wifi_password = {
    owner = "root";
  };
};

# Verwenden
networking.wireless.networks."WLAN".pskFile = config.sops.secrets.wifi_password.path;
```

##### 6. System bauen
"vmware" hier als Beispiel für den DeviceType
```bash
sudo nixos-rebuild switch --flake /etc/nixos#vmware
```

#### Secrets bearbeiten

```bash
sops /etc/nixos/secrets/secrets.yaml
```

## ##Neues Gerät hinzufügen

1. Auf neuem Gerät: `ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N ""`
2. Public Key kopieren: `cat ~/.ssh/sops-key.pub`
3. Auf altem Gerät: Key zu `.sops.yaml` hinzufügen
4. Secrets neu verschlüsseln: `sops updatekeys secrets/secrets.yaml`
5. Committen und pushen
6. Auf neuem Gerät: Pull und rebuild

#### Secrets-Pfade nach Build

Entschlüsselte Secrets landen in:
- `/run/secrets/wifi_password`
- `/run/secrets/github_token`

Nur als angegebener Owner lesbar!

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
