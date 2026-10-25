{
  description = "nix-darwin configuration of endfield";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    asa1984-nvim.url = "github:asa1984/asa1984.nvim";
    llm-agents.url = "github:numtide/llm-agents.nix";
    herdr-splits = {
      url = "github:lmilojevicc/herdr-splits.nvim";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";
    comin.url = "github:nlewo/comin";
    nix-linux-builder.url = "github:input-output-hk/nix-linux-builder";

    # asa1984.nvim の IDE はこちらの pkgs で組まれるので、nixpkgs も揃えておく。
    asa1984-nvim.inputs.nixpkgs.follows = "nixpkgs";
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

        # configs/ も export する。仕事用リポジトリの gaul は
        # `github:asa1984/dotfiles?dir=hosts/endfield` を input にして、
        # lib.makeDarwinConfig とこれらのモジュールを endfield と同じ lock で使う。
        darwinModules = {
          default = import ../../modules/nix-darwin;
        }
        // self.lib.modulesIn ../../configs/nix-darwin;
        homeModules = {
          default = import ../../modules/home-manager;
        }
        // self.lib.modulesIn ../../configs/home-manager;

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
