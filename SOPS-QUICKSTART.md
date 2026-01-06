# sops-nix Schnellstart

## Erste Einrichtung

### 1. sops-key erstellen
```bash
ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N ""
cat ~/.ssh/sops-key.pub
```

### 2. Public Key zu .sops.yaml hinzufügen
```yaml
keys:
  - &main ssh-ed25519 AAAAC3... user@hostname
```

### 3. Secrets-Verzeichnis erstellen
```bash
mkdir -p /etc/nixos/secrets
```

### 4. Erste Secret-Datei erstellen
```bash
nix-shell -p sops --run "sops /etc/nixos/secrets/secrets.yaml"
```

Füge Secrets ein:
```yaml
wifi_password: mein-passwort
github_token: ghp_xxxxx
```

### 5. In configuration.nix nutzen
```nix
sops = {
  defaultSopsFile = ./secrets/secrets.yaml;
  age.sshKeyPaths = [ "/home/stinooo/.ssh/sops-key" ];
  
  secrets.wifi_password = {
    owner = "root";
  };
};

# Verwenden
networking.wireless.networks."WLAN".pskFile = 
  config.sops.secrets.wifi_password.path;
```

### 6. System bauen
```bash
sudo nixos-rebuild switch --flake /etc/nixos#vmware
```

## Secrets bearbeiten

```bash
sops /etc/nixos/secrets/secrets.yaml
```

## Neues Gerät hinzufügen

1. Auf neuem Gerät: `ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N ""`
2. Public Key kopieren: `cat ~/.ssh/sops-key.pub`
3. Auf altem Gerät: Key zu `.sops.yaml` hinzufügen
4. Secrets neu verschlüsseln: `sops updatekeys secrets/secrets.yaml`
5. Committen und pushen
6. Auf neuem Gerät: Pull und rebuild

## Secrets-Pfade nach Build

Entschlüsselte Secrets landen in:
- `/run/secrets/wifi_password`
- `/run/secrets/github_token`

Nur als angegebener Owner lesbar!
