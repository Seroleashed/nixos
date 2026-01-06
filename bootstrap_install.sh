#!/usr/bin/env bash
# bootstrap-install.sh - NixOS Installation
# Ausführen mit: sudo ./bootstrap-install.sh
set -e

# Prüfe ob als root/sudo ausgeführt
if [ "$EUID" -ne 0 ]; then 
  echo "Bitte mit sudo ausführen: sudo ./bootstrap-install.sh"
  exit 1
fi

# Ermittle den echten User (nicht root)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)

# Hardcoded GitHub-Daten
GITHUB_USER="Seroleashed"
GITHUB_REPO="nixos"

echo "═══════════════════════════════════════════════════════════"
echo " NixOS Bootstrap Installation"
echo " Repository: github.com/$GITHUB_USER/$GITHUB_REPO"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Device Type
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

echo ""
echo "Gerätetyp: $DEVICE_TYPE"
echo "User: $REAL_USER"
echo ""
read -p "Starten? [y/N]: " CONFIRM
[ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ] && exit 0

echo ""
echo "[1/11] Lade Git temporär..."

# Repository klonen
echo "[2/11] Clone Repository..."
nix-shell -p git --run "git clone https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git /tmp/nixos-config"

# Hardware-Config sichern
echo "[3/11] Sichere Hardware-Config..."
cp /etc/nixos/hardware-configuration.nix /tmp/hw-backup.nix

# Alte Config entfernen
echo "[4/11] Bereite /etc/nixos vor..."
rm -f /etc/nixos/configuration.nix

# Dateien kopieren
echo "[5/11] Kopiere Dateien..."
cp /tmp/nixos-config/*.nix /etc/nixos/ 2>/dev/null || true
cp /tmp/nixos-config/.sops.yaml /etc/nixos/ 2>/dev/null || true
cp /tmp/nixos-config/.gitignore /etc/nixos/ 2>/dev/null || true
cp /tmp/nixos-config/*.sh /etc/nixos/ 2>/dev/null || true

# Hardware-Config wiederherstellen
echo "[6/11] Stelle Hardware-Config wieder her..."
cp /tmp/hw-backup.nix /etc/nixos/hardware-configuration.nix

# Konfiguration anpassen
echo "[7/11] Passe Konfiguration an..."
sed -i "s/deviceType = \".*\";/deviceType = \"$DEVICE_TYPE\";/" /etc/nixos/device.nix 2>/dev/null || true

if [ "$REAL_USER" != "stinooo" ]; then
  sed -i "s/stinooo/$REAL_USER/g" /etc/nixos/home.nix 2>/dev/null || true
  sed -i "s/stinooo/$REAL_USER/g" /etc/nixos/flake.nix 2>/dev/null || true
  sed -i "s/stinooo/$REAL_USER/g" /etc/nixos/configuration.nix 2>/dev/null || true
fi

read -p "Git Name: " GIT_NAME
read -p "Git Email: " GIT_EMAIL
sed -i "s/userName = \".*\";/userName = \"$GIT_NAME\";/" /etc/nixos/home.nix 2>/dev/null || true
sed -i "s/userEmail = \".*\";/userEmail = \"$GIT_EMAIL\";/" /etc/nixos/home.nix 2>/dev/null || true

# sops-key erstellen (als echter User)
echo "[8/11] Erstelle sops-key..."
sudo -u $REAL_USER mkdir -p "$REAL_HOME/.ssh"
sudo -u $REAL_USER ssh-keygen -t ed25519 -f "$REAL_HOME/.ssh/sops-key" -N "" -q 2>/dev/null || true
echo ""
echo "WICHTIG - Dein sops Public Key:"
cat "$REAL_HOME/.ssh/sops-key.pub"
echo ""
echo "Füge diesen Key zu .sops.yaml hinzu und führe 'sops updatekeys secrets/secrets.yaml' aus"
read -p "Drücke Enter zum Fortfahren..."

# Git initialisieren
echo "[9/11] Initialisiere Git Repository..."
cd /etc/nixos

nix-shell -p git --run "
  git config --global user.name '$GIT_NAME'
  git config --global user.email '$GIT_EMAIL'
  git init 2>/dev/null || true
  
  # WICHTIG: hardware-configuration.nix explizit hinzufügen (auch wenn in .gitignore)
  git add -f hardware-configuration.nix
  
  # Alle anderen Dateien hinzufügen
  git add .
  
  git commit -m 'Initial NixOS configuration' 2>/dev/null || true
  git remote add origin https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git 2>/dev/null || true
"

echo "[10/11] Git Repository bereit!"

# System bauen
echo "[11/11] Baue System (10-30 Minuten)..."
nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " Installation abgeschlossen!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Nach Neustart: gh auth login"
echo ""
read -p "Neustart? [y/N]: " REBOOT
[ "$REBOOT" = "y" ] || [ "$REBOOT" = "Y" ] && reboot
