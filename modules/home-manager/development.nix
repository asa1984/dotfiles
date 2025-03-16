{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development;
in
{
  options.development = {
    enable = mkEnableOption "asa1984-nvim";

    languages = {
      # Configuration languages
      config-lang = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable configuration languages";
        };
      };

      # Programming languages
      c = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable C lang";
        };
      };

      docker = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Docker";
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

      lua = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Lua";
        };
      };

      nix = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Nix";
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

      shell = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Shell";
        };
      };

      terraform = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Terraform";
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
      home.packages =
        optionals cfg.languages.config-lang.enable ([
          pkgs.nodePackages.prettier
          pkgs.taplo
        ])
        ++ optionals cfg.languages.c.enable ([
          pkgs.gcc
          pkgs.clang-tools
        ])
        ++ optionals cfg.languages.docker.enable ([
          pkgs.nodePackages.dockerfile-language-server-nodejs
        ])
        ++ optionals cfg.languages.go.enable ([
          pkgs.go
          pkgs.gopls
        ])
        ++ optionals cfg.languages.haskell.enable ([
          pkgs.ghc
          pkgs.haskell-language-server
          pkgs.haskellPackages.fourmolu
          stack-wrapped
        ])
        ++ optionals cfg.languages.javascript.enable ([
          pkgs.biome
          pkgs.bun
          pkgs.corepack
          pkgs.deno
          pkgs.eslint
          pkgs.nodePackages."@astrojs/language-server"
          pkgs.nodePackages."@tailwindcss/language-server"
          pkgs.nodePackages.graphql-language-service-cli
          pkgs.nodePackages.pnpm
          pkgs.nodePackages.typescript-language-server
          pkgs.nodePackages.vscode-langservers-extracted
          pkgs.nodePackages.yarn
          pkgs.nodejs
          pkgs.nodePackages.prettier
        ])
        ++ optionals cfg.languages.lua.enable ([
          pkgs.lua-language-server
          pkgs.stylua
        ])
        ++ optionals cfg.languages.nix.enable ([
          pkgs.nil
          pkgs.nixfmt-rfc-style
        ])
        ++ optionals cfg.languages.ocaml.enable ([
          pkgs.ocaml
          pkgs.ocamlPackages.dune_3
          pkgs.ocamlPackages.ocaml-lsp
          pkgs.ocamlPackages.ocamlformat
        ])
        ++ optionals cfg.languages.protobuf.enable ([
          pkgs.buf
          pkgs.protobuf
        ])
        ++ optionals cfg.languages.python.enable ([
          pkgs.python312
          pkgs.ruff
          pkgs.pyright
        ])
        ++ optionals cfg.languages.rust.enable ([
          (pkgs.fenix.combine [
            pkgs.fenix.stable.toolchain
            pkgs.fenix.targets.wasm32-unknown-unknown.stable.rust-std
            pkgs.fenix.targets.wasm32-wasi.stable.rust-std
          ])
        ])
        ++ optionals cfg.languages.shell.enable ([
          pkgs.shellcheck
          pkgs.shfmt
        ])
        ++ optionals cfg.languages.terraform.enable ([
          pkgs.terraform
          pkgs.terraform-ls
          pkgs.opentofu
        ])
        ++ optionals cfg.languages.typst.enable ([
          pkgs.typst
          pkgs.tinymist
          pkgs.typstyle
        ])
        ++ optionals cfg.languages.zig.enable ([
          pkgs.zig
          pkgs.zls
        ]);
    };
}
