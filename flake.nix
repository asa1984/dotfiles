{
  description = "NixOS & homa-manager configurations of ASA1984";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    # Others
    rust-overlay.url = "github:oxalica/rust-overlay";
    xremap.url = "github:xremap/nix-flake";
  };

  outputs = inputs:
    {
      nixosConfigurations = (import ./hosts inputs).nixos;
      homeConfigurations = (import ./hosts inputs).home-manager;
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      scripts = with pkgs; [
        (writeScriptBin "switch-home" ''
          home-manager switch --flake ".#$@"
        '')
        (writeScriptBin "switch-nixos" ''
          sudo nixos-rebuild switch --flake ".#$@"
        '')
      ];
    in {
      formatter = pkgs.alejandra;
      devShell = pkgs.mkShell {
        packages = scripts;
      };
    });
}
