{ pkgs, ... }: {
  home.packages = with pkgs; [
    bat # cat alternative
    bottom # top alternative
    exa # ls alternative
    du-dust # du alternative
    fd # find alternative
    httpie # http client
    jq # json parser
    lazydocker # docker tui
    lazygit # git tui
    neofetch # system info
    procs # ps alternative
    ranger # file viewer
    ripgrep # grep alternative
    tokei
  ];
}
