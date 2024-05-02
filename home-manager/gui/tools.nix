{ pkgs, ... }: {
  home.packages = with pkgs; [
    localsend # local file sharing
    obsidian # markdown note
    parsec-bin # extreme first remote desktop client
    remmina # VNC client
    slack
    vscode
    xfce.thunar # GUI file manager
    zoom-us
  ];
}
