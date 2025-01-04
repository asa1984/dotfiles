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
          --no-install-ghc \
          --system-ghc \
        "
    '';
  };
in
{
  home.packages = with pkgs; [
    # Languages
    ## C
    gcc

    ## Go
    go

    ## Haskell
    ghc
    stack-wrapped

    ## JS/TS
    nodejs
    nodePackages.yarn
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
  ];
}
