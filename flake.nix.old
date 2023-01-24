{
  description = "Homa manager flake of ASA1984";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , home-manager
    , hyprland
    , xremap-flake
    , ...
    }:
    let
      user = "asahi";
      stateVersion = "22.11";
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = (
        import ./nixos {
          inherit (nixpkgs) lib;
          inherit inputs user stateVersion system nixpkgs hyprland xremap-flake;
        }
      );
      homeConfigurations = (
        import ./home-manager {
          inherit (nixpkgs) lib;
          inherit inputs user stateVersion system nixpkgs home-manager;
        }
      );
    };
}
