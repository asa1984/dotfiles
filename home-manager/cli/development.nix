{pkgs, ...}: let
  stack-wrapped = pkgs.symlinkJoin {
    name = "stack";
    paths = [pkgs.stack];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/stack \
        --add-flags "\
          --no-nix \
          --system-ghc \
          --no-install-ghc \
        "
    '';
  };
in {
  home.packages = with pkgs; [
    # Languages
    ## C
    gcc

    ## CUE
    cue

    ## Go
    go

    ## Haskell
    ghc
    stack-wrapped

    ## JS/TS
    nodePackages_latest.nodejs
    nodePackages_latest.pnpm
    deno
    bun

    # OCaml
    ocaml
    ocamlPackages.dune_3

    ## Protocol Buffers
    buf
    protobuf

    ## Python
    python312

    ## Rust
    rust-bin.stable.latest.default

    ## Zig
    zig

    # DevOps
    ## Terraform
    terraform

    # Dev Tools
    supabase-cli
  ];
}
