{
  description = "NixOS & homa-manager configurations of ASA1984";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    in {
      formatter = pkgs.alejandra;
    });
}
