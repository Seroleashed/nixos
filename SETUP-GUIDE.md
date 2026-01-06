# Schritt-für-Schritt-Anleitung: NixOS mit GitHub-Config einrichten

Diese Anleitung führt dich durch die komplette Installation von NixOS mit deiner GitHub-Konfiguration.

---

## 📋 Voraussetzungen

- ✅ NixOS frisch installiert (Basis-Installation mit KDE Plasma)
- ✅ System ist gebootet und du bist eingeloggt
- ✅ Netzwerk funktioniert (Internet-Verbindung vorhanden)
- ✅ Deine Konfiguration liegt auf GitHub (z.B. `https://github.com/username/nixos-config`)

---

## 🚀 Teil 1: Vorbereitung (10 Minuten)

### Schritt 1: Öffne ein Terminal

- Drücke `Super` (Windows-Taste) oder klicke auf das KDE-Menü
- Tippe "Konsole" und öffne die Anwendung "Konsole"
- Du siehst jetzt ein schwarzes/weißes Terminal-Fenster

### Schritt 2: Prüfe die Internet-Verbindung

Tippe in das Terminal:

```bash
ping -c 3 google.com
```

**Erwartete Ausgabe:**
```
64 bytes from ... time=...
```

**Falls es nicht funktioniert:**
- Prüfe WLAN/LAN Verbindung
- Öffne Systemeinstellungen → Netzwerk

### Schritt 3: Backup der Original-Konfiguration

Sichere die Original-Hardware-Konfiguration (wichtig!):

```bash
sudo cp /etc/nixos/hardware-configuration.nix /tmp/hardware-backup.nix
```

**Warum?** Diese Datei ist spezifisch für dein Gerät und wird gleich überschrieben.

### Schritt 4: Notiere deinen GitHub-Repository-Namen

Schreibe auf (oder merke dir):
- GitHub Username: `_________________`
- Repository Name: `_________________`

Beispiel: `github.com/MeinName/nixos-config`

---

## 📥 Teil 2: GitHub-Repository klonen (5 Minuten)

### Schritt 5: Wechsle in das NixOS-Verzeichnis

```bash
cd /etc/nixos
```

Du bist jetzt im NixOS-Konfigurations-Verzeichnis.

### Schritt 6: Zeige aktuelle Dateien an

```bash
ls -la
```

**Du siehst:**
```
configuration.nix
hardware-configuration.nix
```

Das sind die Standard-Dateien von der Installation.

### Schritt 7: Lösche die Standard-Dateien (nur configuration.nix)

```bash
sudo rm configuration.nix
```

**WICHTIG:** Wir löschen NICHT die `hardware-configuration.nix`!

### Schritt 8: Clone dein GitHub-Repository

**Ersetze `username` und `nixos-config` mit deinen Daten!**

```bash
sudo nix-shell -p git --run "git clone https://github.com/username/nixos-config.git /tmp/nixos-config"
```

**Beispiel:**
```bash
sudo nix-shell -p git --run "git clone https://github.com/MaxMuster/meine-nixos-config.git /tmp/nixos-config"
```

**Was passiert?**
- Git wird temporär installiert (nur für diesen Befehl)
- Repository wird nach `/tmp/nixos-config` geklont
- Dauert ca. 10-30 Sekunden

**Falls ein Passwort/Token abgefragt wird:**
- Für öffentliche Repositories: Sollte nicht passieren
- Für private Repositories: Gib dein GitHub-Token ein

### Schritt 9: Kopiere die Konfigurationsdateien

```bash
sudo cp /tmp/nixos-config/*.nix /etc/nixos/
sudo cp /tmp/nixos-config/*.sh /etc/nixos/ 2>/dev/null || true
```

**Was passiert?**
- Alle .nix Dateien werden nach `/etc/nixos` kopiert
- Alle .sh Scripts werden kopiert (falls vorhanden)

### Schritt 10: Stelle die Hardware-Konfiguration wieder her

**SEHR WICHTIG:**

```bash
sudo cp /tmp/hardware-backup.nix /etc/nixos/hardware-configuration.nix
```

**Warum?** Die Hardware-Config vom GitHub ist für ein anderes Gerät und würde bei dir nicht funktionieren!

### Schritt 11: Prüfe, welche Dateien jetzt vorhanden sind

```bash
ls -la /etc/nixos/
```

**Du solltest sehen:**
```
flake.nix
configuration.nix
hardware-configuration.nix
home.nix
packages.nix
programs.nix
device.nix
vmware.nix
virtualbox.nix
laptop.nix
desktop.nix
install.sh (optional)
...
```

✅ **Perfekt!** Alle Dateien sind da.

---

## ⚙️ Teil 3: Konfiguration anpassen (5 Minuten)

### Schritt 12: Setze deinen Device-Type

Öffne die Datei `device.nix`:

```bash
sudo nano /etc/nixos/device.nix
```

**Du siehst:**
```nix
let
  deviceType = "vmware";  # <-- HIER ÄNDERN
in
```

**Ändere den Device-Type entsprechend deines Geräts:**

- Für **VMware VM**: Lass es auf `"vmware"`
- Für **VirtualBox VM**: Ändere zu `"virtualbox"`
- Für **Laptop**: Ändere zu `"laptop"`
- Für **Desktop PC**: Ändere zu `"desktop"`

**Beispiel für Laptop:**
```nix
let
  deviceType = "laptop";  # <-- So
in
```

**Speichern und schließen:**
- Drücke `Ctrl + O` (speichern)
- Drücke `Enter` (bestätigen)
- Drücke `Ctrl + X` (schließen)

### Schritt 13: Passe Git-Konfiguration in home.nix an

Öffne `home.nix`:

```bash
sudo nano /etc/nixos/home.nix
```

**Suche nach (ca. Zeile 20-25):**
```nix
programs.git = {
  enable = true;
  userName = "Dein Name";  # <-- HIER ÄNDERN
  userEmail = "deine@email.de";  # <-- HIER ÄNDERN
```

**Ändere auf deine Daten:**
```nix
programs.git = {
  enable = true;
  userName = "Max Mustermann";  # <-- Dein echter Name
  userEmail = "max@beispiel.de";  # <-- Deine echte E-Mail
```

**Speichern und schließen:**
- Drücke `Ctrl + O` → `Enter` → `Ctrl + X`

### Schritt 14: Passe Username in home.nix an (falls anders)

**Nur wenn dein Username NICHT "stinooo" ist!**

```bash
sudo nano /etc/nixos/home.nix
```

**Ändere (Zeile 4-5):**
```nix
home.username = "stinooo";  # <-- Dein Username
home.homeDirectory = "/home/stinooo";  # <-- Dein Home
```

**Auf dein System:**
```nix
home.username = "deinusername";
home.homeDirectory = "/home/deinusername";
```

**Deinen aktuellen Username herausfinden:**
```bash
whoami
```

**Speichern und schließen:** `Ctrl + O` → `Enter` → `Ctrl + X`

### Schritt 15: Passe Username in flake.nix an (falls anders)

**Nur wenn dein Username NICHT "stinooo" ist!**

```bash
sudo nano /etc/nixos/flake.nix
```

**Suche nach allen Stellen mit** `stinooo` **und ersetze sie:**

Beispiel (ca. Zeile 21, 24, 38, etc.):
```nix
home-manager.users.stinooo = import ./home.nix;
```

**Ändere zu:**
```nix
home-manager.users.deinusername = import ./home.nix;
```

**Tipp:** In nano kannst du suchen mit `Ctrl + W` und dann `stinooo` eingeben.

**Speichern und schließen:** `Ctrl + O` → `Enter` → `Ctrl + X`

---

## 🔧 Teil 4: Git initialisieren (3 Minuten)

### Schritt 16: Git-Repository initialisieren

**WICHTIG:** Flakes benötigen ein Git-Repository!

```bash
cd /etc/nixos
sudo git init
```

**Ausgabe:**
```
Initialized empty Git repository in /etc/nixos/.git/
```

### Schritt 17: Alle Dateien zu Git hinzufügen

```bash
sudo git add .
```

**Was passiert?** Alle Dateien werden zum Git-Index hinzugefügt (aber noch nicht committed).

### Schritt 18: Ersten Commit erstellen

```bash
sudo git commit -m "Initial NixOS configuration"
```

**Ausgabe:**
```
[main (root-commit) abc1234] Initial NixOS configuration
 XX files changed, XXXX insertions(+)
```

✅ **Perfekt!** Git ist initialisiert.

---

## 🎯 Teil 5: System bauen und aktivieren (10-30 Minuten)

### Schritt 19: Prüfe die Flake-Konfiguration

```bash
sudo nix flake check /etc/nixos
```

**Erwartete Ausgabe:**
- Entweder: Keine Ausgabe (gut!)
- Oder: Warnungen (können ignoriert werden)

**Falls Fehler:**
- Lies die Fehlermeldung genau
- Häufig: Syntax-Fehler in .nix Dateien
- Prüfe device.nix, home.nix auf Tippfehler

### Schritt 20: Starte den Build-Prozess

**WICHTIG:** Ersetze `vmware` mit deinem Device-Type!

Für VMware:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#vmware
```

Für VirtualBox:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#virtualbox
```

Für Laptop:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

Für Desktop:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

**Was passiert jetzt?**

1. **Inputs werden heruntergeladen** (nixpkgs, home-manager)
   - Zeigt: "fetching tree info..."
   - Dauert: 1-2 Minuten

2. **Pakete werden heruntergeladen**
   - Zeigt: "copying path ... from https://cache.nixos.org"
   - Dauert: 5-20 Minuten (je nach Internet)
   - Du siehst viele Zeilen wie:
     ```
     copying path '/nix/store/...-paket-name' from 'https://cache.nixos.org'...
     ```

3. **System wird konfiguriert**
   - Zeigt: "building /nix/store/..."
   - Dauert: 1-2 Minuten

4. **Services werden gestartet**
   - Zeigt: "starting the following units: ..."
   - Dauert: 10-30 Sekunden

**Fertig, wenn du siehst:**
```
building the system configuration...
activating the configuration...
setting up /etc...
reloading user units for stinooo...
```

✅ **Erfolg!** Dein System ist jetzt konfiguriert!

### Schritt 21: Neustart (empfohlen)

Für sauberen Start mit allen neuen Einstellungen:

```bash
sudo reboot
```

**System startet neu** (dauert ca. 1 Minute).

---

## ✅ Teil 6: Überprüfung und GitHub CLI Setup (5 Minuten)

### Schritt 22: Nach Neustart - Terminal öffnen

Nach dem Neustart:
- Melde dich an
- Öffne "Konsole" (oder versuche Ghostty, falls VMware/Bare Metal)

### Schritt 23: Überprüfe die Shell

```bash
echo $SHELL
```

**Erwartete Ausgabe:**
```
/run/current-system/sw/bin/zsh
```

✅ Zsh ist aktiv!

### Schritt 24: Teste Shell-Features

```bash
# Teste Starship Prompt (sollte schön aussehen mit ➜ Symbol)
pwd

# Teste eza (besseres ls)
ll

# Teste bat (besseres cat)
bat /etc/nixos/device.nix

# Teste fzf (Fuzzy Finder)
# Drücke Ctrl+T und tippe etwas
```

**Alles funktioniert?** ✅ Perfekt!

### Schritt 25: GitHub CLI einrichten

```bash
gh auth login
```

**Interaktiver Prozess:**

```
? What account do you want to log into?
> GitHub.com

? What is your preferred protocol for Git operations?
> HTTPS

? Authenticate Git with your GitHub credentials?
> Yes

? How would you like to authenticate GitHub CLI?
> Login with a web browser

! First copy your one-time code: XXXX-XXXX
Press Enter to open github.com in your browser...
```

**Schritte:**
1. Kopiere den Code (XXXX-XXXX)
2. Drücke Enter
3. Browser öffnet sich
4. Füge den Code ein
5. Autorisiere GitHub CLI

**Fertig, wenn du siehst:**
```
✓ Authentication complete.
✓ Logged in as username
```

### Schritt 26: Teste GitHub CLI

```bash
# Zeige deinen GitHub-Status
gh auth status

# Liste deine Repositories
gh repo list

# Clone ein Repository (Test)
gh repo clone username/nixos-config /tmp/test-clone
```

✅ **Funktioniert alles?** GitHub CLI ist eingerichtet!

---

## 🎉 Teil 7: Fertig! Was jetzt?

### Was du jetzt hast:

✅ NixOS mit deiner kompletten Konfiguration
✅ Home Manager für User-Settings
✅ Git, GitHub CLI (gh) funktionsfähig
✅ Zsh mit Starship, fzf, zoxide, thefuck
✅ Alle deine Programme installiert
✅ Device-spezifische Optimierungen (VMware/Laptop/Desktop)

### Nützliche Befehle:

```bash
# System aktualisieren
sudo nixos-rebuild switch --flake /etc/nixos#vmware

# Änderungen committen und pushen
cd /etc/nixos
sudo git add .
sudo git commit -m "Meine Änderungen"
sudo git push

# Alte Generationen aufräumen
sudo nix-collect-garbage -d

# TheFuck verwenden (Befehl korrigieren)
okay

# Zu anderem Verzeichnis springen (zoxide)
z downloads

# Fuzzy File Search
fzf
```

### Empfohlene nächste Schritte:

1. **GitHub-Repository einrichten für Push:**
   ```bash
   cd /etc/nixos
   sudo git remote add origin https://github.com/username/nixos-config.git
   sudo git push -u origin main
   ```

2. **VS Code öffnen und Extensions installieren:**
   - Öffne VS Code
   - Extensions werden automatisch installiert (falls in home.nix definiert)

3. **KDE-Einstellungen anwenden** (Dark Theme etc.):
   ```bash
   bash /etc/nixos/kde-setup.sh
   ```

4. **Tailscale einrichten** (falls installiert):
   ```bash
   sudo tailscale up
   ```

5. **Docker testen** (falls installiert):
   ```bash
   docker run hello-world
   ```

---

## 🆘 Häufige Probleme und Lösungen

### Problem 1: "cannot find flake"

**Fehler:**
```
error: getting status of '/etc/nixos': No such file or directory
```

**Lösung:**
```bash
cd /etc/nixos
sudo git init
sudo git add .
sudo git commit -m "Initial commit"
```

Git-Repository war nicht initialisiert!

---

### Problem 2: "file 'hardware-configuration.nix' not found"

**Fehler:**
```
error: getting status of '/etc/nixos/hardware-configuration.nix': No such file or directory
```

**Lösung:**
```bash
# Hardware-Config neu generieren
sudo nixos-generate-config --show-hardware-config > /tmp/hw.nix
sudo cp /tmp/hw.nix /etc/nixos/hardware-configuration.nix

# Dann rebuild
sudo nixos-rebuild switch --flake /etc/nixos#vmware
```

---

### Problem 3: Rebuild dauert ewig / hängt

**Was tun:**
- Warte geduldig (beim ersten Mal dauert es länger)
- Internetverbindung prüfen: `ping google.com` (in anderem Terminal)
- Fortschritt anzeigen mit `--show-trace`:
  ```bash
  sudo nixos-rebuild switch --flake /etc/nixos#vmware --show-trace
  ```

---

### Problem 4: "evaluation error" / Syntax-Fehler

**Fehler:**
```
error: syntax error, unexpected ...
```

**Lösung:**
- Prüfe die angegebene Datei und Zeile
- Häufige Fehler:
  - Fehlendes Semikolon `;`
  - Falsche Anführungszeichen
  - Tippfehler in Variablennamen

**Syntax-Check:**
```bash
nix-instantiate --parse /etc/nixos/configuration.nix
nix-instantiate --parse /etc/nixos/home.nix
```

---

### Problem 5: Ghostty startet nicht (in VM)

**Normal in VMs!** Ghostty braucht Hardware-Beschleunigung.

**Lösung:**
- Nutze "Konsole" (KDE Terminal) statt Ghostty
- Oder wechsle zu X11 (beim Login → Session → Plasma X11)

---

### Problem 6: Copy/Paste funktioniert nicht (VMware)

**Lösung:**
```bash
# Services prüfen
systemctl status vmtoolsd
systemctl --user status vmware-user

# Services starten
sudo systemctl start vmtoolsd
systemctl --user start vmware-user

# Test-Script ausführen
bash /etc/nixos/test-vmware.sh
```

---

## 📚 Weitere Hilfe

**Dokumentation lesen:**
```bash
cd /etc/nixos

# Übersicht aller Dateien
cat FILES-OVERVIEW.md | less

# Home Manager Anleitung
cat HOME-MANAGER-GUIDE.md | less

# Device-Type System
cat DEVICE-TYPES.md | less
```

**Im NixOS-Chat fragen:**
- Discord: https://discord.gg/RbvHtGa
- Matrix: #nixos:nixos.org

**Meine Konfiguration durchsuchen:**
- Alle Dateien sind in `/etc/nixos`
- Mit `nano` editieren: `sudo nano /etc/nixos/dateiname.nix`

---

## 🎓 Zusammenfassung: Was du getan hast

1. ✅ GitHub-Repository geklont
2. ✅ Konfigurationsdateien kopiert
3. ✅ Hardware-Config beibehalten (wichtig!)
4. ✅ Device-Type gesetzt
5. ✅ Git-Daten angepasst (Name, Email)
6. ✅ Git-Repository initialisiert
7. ✅ System mit Flakes gebaut
8. ✅ Neustart durchgeführt
9. ✅ GitHub CLI eingerichtet
10. ✅ Alles getestet

**Herzlichen Glückwunsch! 🎉**

Dein NixOS-System ist jetzt vollständig eingerichtet und bereit zur Verwendung!
