{ pkgs, ... }: {
  home.packages = with pkgs; [
    bat # cat alternative
    bottom # top alternative
    exa # ls alternative
    fd # find alternative
    jq # json parser
    lazydocker # docker tui
    lazygit # git tui
    neofetch
    ranger # file viewer
    ripgrep # grep alternative
    tokei
  ];
}
