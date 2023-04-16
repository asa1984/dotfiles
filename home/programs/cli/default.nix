{pkgs, ...}: {
  imports = [
    ./helix
    ./neovim
    ./zsh
    ./direnv.nix
    ./gh.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    # development
    deno
    gcc
    nodejs-slim
    nodePackages.pnpm
    nodePackages.vercel
    nodePackages.wrangler
    python312
    rust-bin.stable.latest.default
    supabase-cli

    # Utilities
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
    unar

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
