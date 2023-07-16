{ pkgs, ... }: {
  home.packages = with pkgs; [
    # GUI file manager
    xfce.thunar

    # Chat
    slack
    teams-for-linux

    # Remote desktop client
    parsec-bin
    remmina

    vscode
  ];
}
