{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal und Shell
    ghostty  # Für echte Hardware (funktioniert nicht in VirtualBox)
    zsh
    tmux
    
    # Shell-Tools
    starship
    zoxide
    fzf
    thefuck  # Korrigiert falsche Befehle
    ripgrep  # Besseres grep, wird von fzf verwendet
    bat      # Besseres cat mit Syntax-Highlighting
    eza      # Besseres ls
    fd       # Besseres find
    
    # Entwicklung
    git
    vscode
    
    # Remote-Tools
    rustdesk
    tailscale
    
    # System-Tools
    htop
    neofetch
    
    # Hilfreich für Debugging
    wayland-utils
    xwayland
  ];
}
