#!/usr/bin/env bash
# NixOS Auto-Installation Script mit Home Manager
# Führe dieses Script nach der minimalen NixOS-Installation aus

set -e  # Bei Fehler abbrechen

# Prüfe ob als root/sudo ausgeführt
if [ "$EUID" -ne 0 ]; then
  echo "Bitte mit sudo ausführen: sudo ./bootstrap-install.sh"
  exit 1
fi

echo "=== NixOS Auto-Setup Script mit Home Manager ==="
echo ""

# Ermittle den echten User (nicht root)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)

# Variablen anpassen
GITHUB_USER="Seroleashed"
GITHUB_REPO="nixos"
GITHUB_BRANCH="main"

# Device Type Detection
echo "Wähle deinen Gerätetyp:"
echo "1) VMware Workstation/Player"
echo "2) Raspberry Pi 4B"
echo "3) Laptop"
echo "4) Desktop PC"
read -p "Auswahl [1-4]: " device_choice

case $device_choice in
  1) DEVICE_TYPE="vmware" ;;
  2) DEVICE_TYPE="raspberry" ;;
  3) DEVICE_TYPE="laptop" ;;
  4) DEVICE_TYPE="desktop" ;;
  *) echo "Ungültige Auswahl!"; exit 1 ;;
esac

echo ""
echo "Gerätetyp: $DEVICE_TYPE"
echo "User: $REAL_USER"
echo ""
read -p "Starten? [y/N]: " CONFIRM
[ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ] && exit 0

echo "[1/11] Clone Configuration von GitHub..."
cd /tmp
rm -rf $GITHUB_REPO 2>/dev/null || true
git clone https://github.com/$GITHUB_USER/$GITHUB_REPO.git
cd $GITHUB_REPO


# Hardware-Config sichern
echo "[2/11] Sichere Hardware-Config..."
cp /etc/nixos/hardware-configuration.nix /tmp/hw-backup.nix

# Alte Config entfernen
echo "[3/11] Bereite /etc/nixos vor..."
sudo rm -f /etc/nixos/configuration.nix

echo ""
echo "[4/11] Kopiere Configuration nach /etc/nixos..."
sudo cp flake.nix /etc/nixos/
sudo cp configuration.nix /etc/nixos/
sudo cp packages.nix /etc/nixos/
sudo cp home.nix /etc/nixos/
sudo cp device.nix /etc/nixos/
sudo cp sops.nix /etc/nixos/
sudo cp .sops.yaml /etc/nixos/
sudo cp $DEVICE_TYPE.nix /etc/nixos/

# Device-Type setzen
echo ""
echo "[5/11] Setze Device-Type auf: $DEVICE_TYPE"
sudo sed -i "s/deviceType = \".*\";/deviceType = \"$DEVICE_TYPE\";/" /etc/nixos/device.nix

# Konfiguration
echo "[6/11] Passe konfiguration an..."
if [ "$REAL_USER" != "stinooo" ]; then
  sed -i "s/stinooo/$REAL_USER/g" /etc/nixos/home.nix 2>/dev/null || true
  sed -i "s/stinooo/$REAL_USER/g" /etc/nixos/flake.nix 2>/dev/null || true
  sed -i "s/stinooo/$REAL_USER/g" /etc/nixos/configuration.nix 2>/dev/null || true
fi

read -p "Git Name: " GIT_NAME
read -p "Git Email: " GIT_EMAIL
sed -i "s/userName = \".*\";/userName = \"$GIT_NAME\";/" /etc/nixos/home.nix 2>/dev/null || true
sed -i "s/userEmail = \".*\";/userEmail = \"$GIT_EMAIL\";/" /etc/nixos/home.nix 2>/dev/null || true

# Hardware-Configuration beibehalten (wird bei Installation erstellt)
echo ""
echo "[7/11] Hardware-Configuration bleibt erhalten (nicht überschreiben!)"
sudo cp /tmp/hw-backup.nix /etc/nixos/hardware-configuration.nix

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

# Git initialisieren (wichtig für Flakes!)
echo ""
echo "[9/11] Git initialisieren (für Flakes erforderlich)..."
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

echo ""
echo "[10/11] Erste System-Rebuild mit Flakes und Home Manager..."
echo "   Das kann einige Minuten dauern..."
sudo nixos-rebuild switch --flake /etc/nixos#$DEVICE_TYPE

echo ""
echo "=== Installation abgeschlossen! ==="
echo ""
echo "Gerätetyp: $DEVICE_TYPE"
echo ""
echo "Nach Neustart: gh auth login"
echo ""
read -p "Neustart? [y/N]: " REBOOT
[ "$REBOOT" = "y" ] || [ "$REBOOT" = "Y" ] && reboot

