{pkgs, ...}: {
  imports = [
    ./helix
    ./neovim
    ./zsh
    ./gh.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    # Utils
    bat # cat alternative
    bottom # top alternative
    exa # ls alternative
    du-dust # du alternative
    duf # df alternative
    fd # find alternative
    fzf # fazzy finder
    httpie # http client
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

    # Rice
    neofetch
    pfetch
    nitch

    # Joke
    pingu
    figlet
    lolcat
    cowsay
    tty-clock
  ];
}
