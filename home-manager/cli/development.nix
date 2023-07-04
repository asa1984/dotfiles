{pkgs, ...}: {
  home.packages = with pkgs; [
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
  ];
}