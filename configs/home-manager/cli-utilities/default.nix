{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Coreutils replacements
    bat # cat alternative
    du-dust # du alternative
    duf # df alternative
    eza # ls alternative
    fd # find alternative
    ripgrep # grep alternative

    # Utilities
    bottom # top alternative
    fx # json viewer
    fzf # fazzy finder
    ghq # git repository manager
    httpie # http client
    imagemagick # image manipulation
    jq # json parser
    killall # process killer
    lazydocker # docker tui
    nh # nix cli helper
    nurl # generate nix fetcher
    procs # ps alternative
    silicon # code to image
    speedtest-cli # speedtest
    tokei # analyze code statistics
    typos # find typos
    yazi # file manager

    # Archives
    unar
    unrar
    unzip
    zip

    # Rice
    fastfetch
  ];
}
