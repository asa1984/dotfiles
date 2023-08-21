{pkgs, ...}: {
  home.packages = with pkgs; [
    # C
    gcc

    # Go
    go

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

    # Terraform
    terraform

    # Dev CLI
    supabase-cli
  ];
}
