{pkgs, ...}: {
  imports = [
    ./neovim
    ./zsh
    ./development.nix
    ./direnv.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    # Utilities
    bat # cat alternative
    bottom # top alternative
    exa # ls alternative
    du-dust # du alternative
    duf # df alternative
    fd # find alternative
    fzf # fazzy finder
    httpie # http client
    imagemagick # image manipulation
    jq # json parser
    killall # process killer
    lazydocker # docker tui
    lazygit # git tui
    procs # ps alternative
    ranger # file viewer
    ripgrep # grep alternative
    silicon # code to image

    # Archives
    zip
    unzip
    unrar
    unar

    # Rice
    neofetch
    pfetch
    nitch
    tty-clock

    # Joke
    pingu
    figlet
    lolcat
    cowsay
  ];
}
