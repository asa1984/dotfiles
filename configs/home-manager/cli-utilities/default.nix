{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Coreutils replacements
    bat # cat alternative
    bottom # top alternative
    dust # du alternative
    duf # df alternative
    eza # ls alternative
    fd # find alternative
    ripgrep # grep alternative

    # Utilities
    ffmpeg # media manipulation
    fx # json viewer
    fzf # fazzy finder
    ghq # git repository manager
    go-task # task runner
    httpie # http client
    imagemagick # image manipulation
    jq # json parser
    killall # process killer
    lazydocker # docker tui
    nh # nix cli helper
    nix-update # nix package updater
    nurl # generate nix fetcher
    nvfetcher # nix fetcher
    procs # ps alternative
    silicon # code to image
    speedtest-cli # speedtest
    tokei # analyze code statistics
    typos # find typos
    wget # web downloader
    yazi # file manager
    zellij # terminal multiplexer

    # Archives
    unar
    unrar
    unzip
    zip

    # Rice
    fastfetch

    # Agents
    claude-code-minimal
    codex
    cursor-cli
  ];
}
