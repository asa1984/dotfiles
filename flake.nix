{
  description = "NixOS & homa-manager configurations of asa1984";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # Inner deps
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    # NixOS hardware configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        crane.follows = "crane";
        rust-overlay.follows = "rust-overlay";
      };
    };

    # Remote deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    # My personal pre-configured Neovim
    asa1984-nvim.url = "github:asa1984/asa1984.nvim";

    # Rust toolchain
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Key remapper
    xremap = {
      url = "github:xremap/nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        crane.follows = "crane";
        hyprland.follows = "hyprland";
        home-manager.follows = "home-manager";
      };
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland/v0.45.0";
    hyprsome = {
      url = "github:sopa0/hyprsome";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # crane.follows = "crane";
        flake-utils.follows = "flake-utils";
      };
    };

    # TUI RSS feed reader
    # syndicationd.url = "github:ymgyt/syndicationd";

    # WezTerm
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-linux" # 64-bit x86 Linux
        "aarch64-darwin" # 64-bit ARM macOS
        "x86_64-darwin" # 64-bit x86 macOS
      ];

      imports = [
        inputs.git-hooks.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      flake = {
        nixosConfigurations = (import ./hosts inputs).nixos;

        homeConfigurations = (import ./hosts inputs).home-manager;

        deploy = {
          sshUser = "asahi";
          user = "root";
          nodes = {
            rhine = {
              hostname = "rhine";
              profiles.system = {
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.rhine;
              };
            };
          };
        };
      };

      perSystem =
        {
          config,
          system,
          pkgs,
          lib,
          ...
        }:
        {
          packages = import ./pkgs pkgs;

          pre-commit = {
            check.enable = true;
            settings = {
              src = ./.;
              hooks = {
                shellcheck.enable = true;
                treefmt.enable = true;
              };
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              rustfmt.enable = true;
              stylua.enable = true;
              taplo.enable = true;
            };
          };

          devShells = {
            default = pkgs.mkShell {
              packages = (
                with pkgs;
                [
                  sops
                  age
                  ssh-to-age
                ]
              );
              shellHook = config.pre-commit.installationScript;
            };
          };

          apps = {
            deploy = {
              type = "app";
              program = "${inputs.deploy-rs.packages.${system}.default}/bin/deploy";
            };
          };
        };
    };
}
