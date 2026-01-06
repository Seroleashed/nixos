#!/usr/bin/env bash
# NixOS Auto-Installation Script mit Home Manager
# Führe dieses Script nach der minimalen NixOS-Installation aus

set -e  # Bei Fehler abbrechen

echo "=== NixOS Auto-Setup Script mit Home Manager ==="
echo ""

# Variablen anpassen
GITHUB_USER="Seroleashed"
GITHUB_REPO="nixos"
GITHUB_BRANCH="main"

# Device Type Detection
echo "Wähle deinen Gerätetyp:"
echo "1) VMware Workstation/Player"
echo "2) VirtualBox"
echo "3) Laptop"
echo "4) Desktop PC"
read -p "Auswahl [1-4]: " device_choice

case $device_choice in
  1) DEVICE_TYPE="vmware" ;;
  2) DEVICE_TYPE="virtualbox" ;;
  3) DEVICE_TYPE="laptop" ;;
  4) DEVICE_TYPE="desktop" ;;
  *) echo "Ungültige Auswahl!"; exit 1 ;;
esac

echo ""
echo "Ausgewählter Gerätetyp: $DEVICE_TYPE"
echo ""

echo "1. Clone Configuration von GitHub..."
cd /tmp
rm -rf $GITHUB_REPO 2>/dev/null || true
git clone https://github.com/$GITHUB_USER/$GITHUB_REPO.git
cd $GITHUB_REPO

echo ""
echo "2. Kopiere Configuration nach /etc/nixos..."
sudo cp flake.nix /etc/nixos/
sudo cp configuration.nix /etc/nixos/
sudo cp packages.nix /etc/nixos/
sudo cp programs.nix /etc/nixos/
sudo cp home.nix /etc/nixos/
sudo cp device.nix /etc/nixos/
sudo cp vmware.nix /etc/nixos/
sudo cp virtualbox.nix /etc/nixos/
sudo cp laptop.nix /etc/nixos/
sudo cp desktop.nix /etc/nixos/

# Device-Type setzen
echo ""
echo "3. Setze Device-Type auf: $DEVICE_TYPE"
sudo sed -i "s/deviceType = \".*\";/deviceType = \"$DEVICE_TYPE\";/" /etc/nixos/device.nix

# Hardware-Configuration beibehalten (wird bei Installation erstellt)
echo ""
echo "4. Hardware-Configuration bleibt erhalten (nicht überschreiben!)"

# Git initialisieren (wichtig für Flakes!)
echo ""
echo "5. Git initialisieren (für Flakes erforderlich)..."
cd /etc/nixos
sudo git init 2>/dev/null || true
sudo git add .
sudo git commit -m "Initial NixOS configuration with Home Manager" 2>/dev/null || true
sudo git remote add origin https://github.com/$GITHUB_USER/$GITHUB_REPO.git 2>/dev/null || true

echo ""
echo "6. Erste System-Rebuild mit Flakes und Home Manager..."
echo "   Das kann einige Minuten dauern..."
sudo nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE

echo ""
echo "=== Installation abgeschlossen! ==="
echo ""
echo "Gerätetyp: $DEVICE_TYPE"
echo ""
echo "Nächste Schritte:"
echo ""
echo "1. GitHub CLI einrichten:"
echo "   gh auth login"
echo ""
echo "2. Git konfigurieren:"
echo "   Bearbeite /etc/nixos/home.nix:"
echo "   - userName = \"Dein Name\""
echo "   - userEmail = \"deine@email.de\""
echo "   sudo nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE"
echo ""
echo "3. Terminal starten (Ghostty oder Konsole)"
echo ""
echo "4. Shell testen:"
echo "   - okay (TheFuck)"
echo "   - z (Zoxide)"
echo "   - fzf"
echo "   - gh repo list"
echo ""

if [ "$DEVICE_TYPE" = "vmware" ]; then
  echo "VMware-spezifisch:"
  echo "- Copy/Paste sollte funktionieren"
  echo "- Test: bash test-vmware.sh (falls vorhanden)"
  echo "- Falls Probleme: systemctl --user status vmware-user"
  echo ""
fi

if [ "$DEVICE_TYPE" = "laptop" ]; then
  echo "Laptop-spezifisch:"
  echo "- TLP Power Management ist aktiviert"
  echo "- Prüfe Status: tlp-stat"
  echo "- Helligkeit: brightnessctl set 50%"
  echo ""
fi

echo "Änderungen synchronisieren:"
echo "  cd /etc/nixos"
echo "  # Änderungen in home.nix oder configuration.nix"
echo "  sudo nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE"
echo "  sudo git add ."
echo "  sudo git commit -m 'Update config'"
echo "  sudo git push"
echo ""
echo "Auf anderem Gerät:"
echo "  cd /etc/nixos"
echo "  sudo git pull"
echo "  sudo nixos-rebuild switch --flake /etc/nixos#[device-type]"
echo ""
echo "Viel Spaß mit NixOS + Home Manager!"

