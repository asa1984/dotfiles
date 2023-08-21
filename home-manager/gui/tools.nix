{pkgs, ...}: {
  home.packages = with pkgs; [
    # GUI file manager
    xfce.thunar

    # Chat
    slack

    # Remote desktop client
    parsec-bin
    remmina

    # Note
    obsidian

    vscode
  ];
}
