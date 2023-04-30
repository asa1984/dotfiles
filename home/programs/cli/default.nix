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
    # Development

    # C
    gcc

    # Haskell
    cabal2nix
    ghc
    haskellPackages.cabal-install
    haskellPackages.stack

    # JS/TS (Deno)
    deno

    # JS/TS (Node)
    nodejs-slim
    nodePackages.pnpm
    nodePackages.vercel
    nodePackages.wrangler

    # Python
    python312

    # Rust
    rust-bin.stable.latest.default

    # Dev CLI
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
