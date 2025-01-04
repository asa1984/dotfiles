{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.languages;
in
{
  options.languages = {
    enable = mkEnableOption "Development";

    c = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable C lang";
      };
    };

    go = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Go lang";
      };
    };

    haskell = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Haskell";
      };
    };

    javascript = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable JavaScript";
      };
    };

    ocaml = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OCaml";
      };
    };

    protobuf = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Protocol Buffers";
      };
    };

    python = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Python";
      };
    };

    rust = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Rust";
      };
    };

    typst = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Typst";
      };
    };

    zig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Zig";
      };
    };
  };

  config =
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
    mkIf cfg.enable {
      # home.packages = [ ];
      home.packages =
        optionals cfg.c.enable ([
          pkgs.gcc
          pkgs.clang-tools
        ])
        ++ optionals cfg.go.enable ([ pkgs.go ])
        ++ optionals cfg.haskell.enable ([
          pkgs.ghc
          stack-wrapped
        ])
        ++ optionals cfg.javascript.enable ([
          pkgs.nodejs
          pkgs.corepack
          pkgs.nodePackages.yarn
          pkgs.nodePackages.pnpm
          pkgs.deno
          pkgs.bun
        ])
        ++ optionals cfg.ocaml.enable ([
          pkgs.ocaml
          pkgs.ocamlPackages.dune_3
        ])
        ++ optionals cfg.protobuf.enable ([
          pkgs.buf
          pkgs.protobuf
        ])
        ++ optionals cfg.python.enable ([ pkgs.python312 ])
        ++ optionals cfg.rust.enable ([
          (pkgs.fenix.combine [
            pkgs.fenix.stable.toolchain
            pkgs.fenix.targets.wasm32-unknown-unknown.stable.rust-std
            pkgs.fenix.targets.wasm32-wasi.stable.rust-std
          ])
        ])
        ++ optionals cfg.typst.enable ([
          pkgs.typst
        ])
        ++ optionals cfg.zig.enable ([ pkgs.zig ]);
    };
}
