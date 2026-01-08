{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Terminal und Shell
    zsh
    tmux

    # Shell-Tools
    starship
    zoxide
    pay-respects
    fzf
    ripgrep # Besseres grep, wird von fzf verwendet
    bat # Besseres cat mit Syntax-Highlighting
    eza # Besseres ls
    fd # Besseres find
    navi # cheatsheet for commands

    # Entwicklung
    git
    vscode

    # Remote-Tools
    rustdesk
    tailscale

    # System-Tools
    htop
    neofetch
    sops
    age
    ssh-to-age


    # Hilfreich für Debugging
    wayland-utils
    xwayland
  ];
}
