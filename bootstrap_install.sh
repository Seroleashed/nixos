#!/usr/bin/env bash
# bootstrap-install.sh - NixOS Installation mit öffentlichem GitHub-Repository
set -e

echo "═══════════════════════════════════════════════════════════"
echo " NixOS Bootstrap Installation (Öffentliches Repository)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# GitHub-Daten
read -p "GitHub Username: " GITHUB_USER
read -p "Repository Name: " GITHUB_REPO

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
echo "GitHub: $GITHUB_USER/$GITHUB_REPO"
echo "Gerätetyp: $DEVICE_TYPE"
echo "Username: $CURRENT_USER"
echo ""
read -p "Starten? [y/N]: " CONFIRM
[ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ] && exit 0

# Git laden
echo ""
echo "[1/9] Lade Git..."
export PATH="$PATH:$(nix-build '<nixpkgs>' -A git --no-out-link)/bin"

# Repository klonen (öffentlich, kein Token!)
echo "[2/9] Clone Repository..."
git clone "https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git" /tmp/nixos-config

# Hardware-Config sichern
echo "[3/9] Sichere Hardware-Config..."
sudo cp /etc/nixos/hardware-configuration.nix /tmp/hw-backup.nix

# Dateien kopieren
echo "[4/9] Kopiere Dateien..."
sudo cp /tmp/nixos-config/*.nix /etc/nixos/ 2>/dev/null || true
sudo cp /tmp/nixos-config/.sops.yaml /etc/nixos/ 2>/dev/null || true
sudo cp /tmp/nixos-config/.gitignore /etc/nixos/ 2>/dev/null || true

# Hardware-Config wiederherstellen
echo "[5/9] Stelle Hardware-Config wieder her..."
sudo cp /tmp/hw-backup.nix /etc/nixos/hardware-configuration.nix

# Konfiguration anpassen
echo "[6/9] Passe Konfiguration an..."
sudo sed -i "s/deviceType = \".*\";/deviceType = \"$DEVICE_TYPE\";/" /etc/nixos/device.nix 2>/dev/null || true

if [ "$CURRENT_USER" != "stinooo" ]; then
  sudo sed -i "s/stinooo/$CURRENT_USER/g" /etc/nixos/home.nix 2>/dev/null || true
  sudo sed -i "s/stinooo/$CURRENT_USER/g" /etc/nixos/flake.nix 2>/dev/null || true
  sudo sed -i "s/stinooo/$CURRENT_USER/g" /etc/nixos/configuration.nix 2>/dev/null || true
fi

read -p "Git Name: " GIT_NAME
read -p "Git Email: " GIT_EMAIL
sudo sed -i "s/userName = \".*\";/userName = \"$GIT_NAME\";/" /etc/nixos/home.nix 2>/dev/null || true
sudo sed -i "s/userEmail = \".*\";/userEmail = \"$GIT_EMAIL\";/" /etc/nixos/home.nix 2>/dev/null || true

# sops-key erstellen
echo "[7/9] Erstelle sops-key..."
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/sops-key -N "" -q
echo ""
echo "WICHTIG - Dein sops Public Key:"
cat ~/.ssh/sops-key.pub
echo ""
echo "Füge diesen Key zu .sops.yaml auf einem konfigurierten Gerät hinzu"
echo "und führe dort 'sops updatekeys secrets/secrets.yaml' aus"
read -p "Drücke Enter wenn erledigt (oder überspringe für erste Installation)..."

# Git initialisieren
echo "[8/9] Initialisiere Git..."
cd /etc/nixos
sudo git init
sudo git add .
sudo git commit -m "Initial" 2>/dev/null || true
sudo git remote add origin "https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git" 2>/dev/null || true

# System bauen
echo "[9/9] Baue System (10-30 Minuten)..."
sudo nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE

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
[ "$REBOOT" = "y" ] || [ "$REBOOT" = "Y" ] && sudo reboot
