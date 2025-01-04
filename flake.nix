{
  description = "NixOS & homa-manager configurations of asa1984";

  inputs = {
    # Nixpkgs
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Modules
    deploy-rs.url = "github:serokell/deploy-rs";
    home-manager.url = "github:nix-community/home-manager";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.1";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";

    # Overlays
    fenix.url = "github:nix-community/fenix";

    # Packages
    asa1984-nvim.url = "github:asa1984/asa1984.nvim";
    hyprland.url = "github:hyprwm/Hyprland/v0.46.2";
    hyprsome.url = "github:sopa0/hyprsome";
    wezterm.url = "github:wez/wezterm?dir=nix";
    xremap.url = "github:xremap/nix-flake";

    # Inner deps
    flake-utils.url = "github:numtide/flake-utils";

    asa1984-nvim.inputs.git-hooks.follows = "";
    deploy-rs.inputs.flake-compat.follows = "";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    git-hooks.inputs.flake-compat.follows = "";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.pre-commit-hooks.follows = "";
    hyprsome.inputs.flake-utils.follows = "flake-utils";
    hyprsome.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.flake-compat.follows = "";
    lanzaboote.inputs.pre-commit-hooks-nix.follows = "";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    xremap.inputs.flake-parts.follows = "flake-parts";
    xremap.inputs.home-manager.follows = "home-manager";
    xremap.inputs.hyprland.follows = "hyprland";
    xremap.inputs.nixpkgs.follows = "nixpkgs";
    xremap.inputs.treefmt-nix.follows = "treefmt-nix";
  };

  outputs =
    rawInputs@{ self, ... }:
    let
      inputs = rawInputs // {
        private-modules = builtins.getFlake "github:asa1984/private-modules/718b83e5ae0b0165ef340e3992aced8cae1afa74";
      };
    in
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
        lib = import ./lib inputs;

        overlays = import ./overlays inputs;

        nixosModules.default = import ./modules/nixos;
        nixosConfigurations = (import ./hosts inputs).nixos;

        homeManagerModules.default = import ./modules/home-manager;
        homeConfigurations = (import ./hosts inputs).home-manager;

        darwinModules.default = import ./modules/nix-darwin;
        darwinConfigurations = {
          gaul = self.lib.makeDarwinConfig {
            system = "aarch64-darwin";
            hostname = "gaul";
            username = "asahi";
            theme = "tokyonight-moon";
            modules = [ ./hosts/gaul/nix-darwin.nix ];
          };
        };

        deploy = {
          sshUser = "asahi";
          user = "root";
          nodes = {
            rhine = {
              hostname = "rhine";
              profiles.system = {
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.rhine;
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

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              rustfmt.enable = true;
              stylua.enable = true;
              taplo.enable = true;
            };
          };

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
        };
    };
}
