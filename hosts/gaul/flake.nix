{
  description = "nix-darwin configuration of gaul";

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

    fenix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    rawInputs@{ self, ... }:
    let
      # private-modules is intentionally not a locked input (private repo).
      inputs = rawInputs // {
        private-modules = builtins.getFlake "github:asa1984/private-modules/718b83e5ae0b0165ef340e3992aced8cae1afa74";
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      flake = {
        lib = import ../../lib inputs;

        overlays = import ../../overlays inputs;

        darwinModules.default = import ../../modules/nix-darwin;
        darwinConfigurations = {
          gaul = self.lib.makeDarwinConfig {
            system = "aarch64-darwin";
            hostname = "gaul";
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
