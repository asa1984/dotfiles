{
  description = "nix-darwin configuration of endfield";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    asa1984-nvim.url = "github:asa1984/asa1984.nvim";
    llm-agents.url = "github:numtide/llm-agents.nix";
    herdr-splits = {
      url = "github:lmilojevicc/herdr-splits.nvim";
      flake = false;
    };
    fenix.url = "github:nix-community/fenix";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";
    comin.url = "github:nlewo/comin";
    nix-linux-builder.url = "github:input-output-hk/nix-linux-builder";

    fenix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    comin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      flake = {
        lib = import ../../lib inputs;

        overlays = import ../../overlays inputs;

        darwinModules.default = import ../../modules/nix-darwin;
        darwinConfigurations = {
          endfield = self.lib.makeDarwinConfig {
            system = "aarch64-darwin";
            hostname = "endfield";
            username = "asahi";
            theme = "tokyonight-moon";
            modules = [ ./nix-darwin.nix ];
          };
        };
      };

      perSystem =
        {
          system,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          packages = import ../../pkgs pkgs;
        };
    };
}
