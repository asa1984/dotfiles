{ pkgs, ... }:
let
  stack-wrapped = pkgs.symlinkJoin {
    name = "stack";
    paths = [ pkgs.stack ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/stack \
        --add-flags "\
          --no-nix \
          --system-ghc \
          --no-install-ghc \
        "
    '';
  };
in
{
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
    nodejs-slim
    nodePackages.pnpm
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
    (fenix.combine [
      fenix.stable.toolchain
      fenix.targets.wasm32-unknown-unknown.stable.rust-std
      fenix.targets.wasm32-wasi.stable.rust-std
    ])

    ## Zig
    zig

    # DevOps
    ## Terraform
    # terraform

    # Dev Tools
    supabase-cli
  ];
}
