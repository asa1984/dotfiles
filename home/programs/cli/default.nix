{pkgs, ...}: {
  improts = [
    ./helix
    ./neovim
    ./zsh
    ./gh.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    bat # cat alternative
    bottom # top alternative
    exa # ls alternative
    du-dust # du alternative
    duf # df alternative
    fd # find alternative
    httpie # http client
    jq # json parser
    killall # process killer
    lazydocker # docker tui
    lazygit # git tui
    neofetch # system info
    procs # ps alternative
    ranger # file viewer
    ripgrep # grep alternative
    fzf # fazzy finder

    # funny
    pingu
    figlet
    lolcat
    cowsay
    tty-clock
  ];
}
