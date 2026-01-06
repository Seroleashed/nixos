#!/usr/bin/env bash
# bootstrap-install.sh - NixOS Installation mit öffentlichem GitHub-Repository
set -e

echo "═══════════════════════════════════════════════════════════"
echo " NixOS Bootstrap Installation (Öffentliches Repository)"
echo "═══════════════════════════════════════════════════════════"

# Device Type
echo ""
echo "Gerätetyp:"
echo "1) VMware  2) VirtualBox  3) Laptop  4) Desktop"
read -p "Auswahl [1-4]: " device_choice

case $device_choice in
  1) DEVICE_TYPE="vmware" ;;
  2) DEVICE_TYPE="virtualbox" ;;
  3) DEVICE_TYPE="laptop" ;;
  4) DEVICE_TYPE="desktop" ;;
  *) echo "Ungültig!"; exit 1 ;;
esac

CURRENT_USER=$(whoami)

echo ""
echo "Gerätetyp: $DEVICE_TYPE"
echo "Username: $CURRENT_USER"
echo ""
read -p "Starten? [y/N]: " CONFIRM
[ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ] && exit 0

# Git temporär in nix-shell laden
echo ""
echo "[1/11] Lade Git temporär..."

# Repository klonen (öffentlich, kein Token!)
echo "[2/11] Clone Repository..."
nix-shell -p git --run "git clone https://github.com/Seroleashed/nixos.git /tmp/nixos-config"

# Hardware-Config sichern
echo "[3/11] Sichere Hardware-Config..."
cp /etc/nixos/hardware-configuration.nix /tmp/hw-backup.nix

# Alte Config entfernen (aber hardware-configuration.nix behalten!)
echo "[4/11] Entferne alte Konfigs..."
rm -f /etc/nixos/configuration.nix

# Dateien kopieren
echo "[5/11] Kopiere Dateien..."
cp /tmp/nixos-config/*.nix /etc/nixos/ 2>/dev/null || true
cp /tmp/nixos-config/.sops.yaml /etc/nixos/ 2>/dev/null || true
cp /tmp/nixos-config/.gitignore /etc/nixos/ 2>/dev/null || true
cp /tmp/nixos-config/*.sh /etc/nixos/ 2>/dev/null || true

# Hardware-Config wiederherstellen (überschreibt die vom Repo!)
echo "[6/11] Stelle Hardware-Config wieder her..."
cp /tmp/hw-backup.nix /etc/nixos/hardware-configuration.nix

# Konfiguration anpassen
echo "[7/11] Passe Konfiguration an..."
sed -i "s/deviceType = \".*\";/deviceType = \"$DEVICE_TYPE\";/" /etc/nixos/device.nix 2>/dev/null || true

if [ "$CURRENT_USER" != "stinooo" ]; then
  sed -i "s/stinooo/$CURRENT_USER/g" /etc/nixos/home.nix 2>/dev/null || true
  sed -i "s/stinooo/$CURRENT_USER/g" /etc/nixos/flake.nix 2>/dev/null || true
  sed -i "s/stinooo/$CURRENT_USER/g" /etc/nixos/configuration.nix 2>/dev/null || true
fi

read -p "Git Name: " GIT_NAME
read -p "Git Email: " GIT_EMAIL
sed -i "s/userName = \".*\";/userName = \"$GIT_NAME\";/" /etc/nixos/home.nix 2>/dev/null || true
sed -i "s/userEmail = \".*\";/userEmail = \"$GIT_EMAIL\";/" /etc/nixos/home.nix 2>/dev/null || true

# sops-key erstellen
echo "[8/11] Erstelle sops-key..."
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N "" -q 2>/dev/null || true
echo ""
echo "WICHTIG - Dein sops Public Key:"
cat ~/.ssh/sops-key.pub
echo ""
echo "Füge diesen Key zu .sops.yaml auf einem konfigurierten Gerät hinzu"
echo "und führe dort 'sops updatekeys secrets/secrets.yaml' aus"
read -p "Drücke Enter wenn erledigt (oder überspringe für erste Installation)..."

# Git initialisieren und commiten (WICHTIG für Flakes!)
echo "[9/11] Initialisiere Git Repository..."
cd /etc/nixos

# Git in nix-shell verfügbar machen für die folgenden Befehle
nix-shell -p git --run "
  # Git-Config setzen (erforderlich für commit)
  git config --global user.name '$GIT_NAME'
  git config --global user.email '$GIT_EMAIL'
  
  # Repository initialisieren
  git init 2>/dev/null || true
  
  # Hardware-Config aus Git entfernen (gerätespezifisch!)
  echo 'hardware-configuration.nix' >> .gitignore
  
  # Alle Dateien hinzufügen
  git add .
  
  # Initialen Commit erstellen
  git commit -m 'Initial NixOS configuration' 2>/dev/null || true
  
  # Remote hinzufügen
  git remote add origin https://github.com/Seroleashed/nixos.git 2>/dev/null || true
"

echo "[10/11] Git Repository committed und bereit!"

# System bauen
echo "[11/11] Baue System (10-30 Minuten)..."
nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " Installation abgeschlossen!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Nach Neustart:"
echo "1. gh auth login (Browser-Login)"
echo "2. Falls Secrets: .sops.yaml aktualisieren und sops updatekeys"
echo ""
read -p "Neustart? [y/N]: " REBOOT
[ "$REBOOT" = "y" ] || [ "$REBOOT" = "Y" ] && reboot
