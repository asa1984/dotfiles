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
    xremap-flake.url = "github:xremap/flake";
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
    in
    {
      nixosConfigurations = (
        import ./nixos {
          inherit (nixpkgs) lib;
          inherit inputs user stateVersion nixpkgs home-manager hyprland xremap-flake;
        }
      );
      #      homeConfigurations = (
      #        import ./home {
      #          inherit (nixpkgs) lib;
      #          inherit inputs user nixpkgs home-manager;
      #        }
      #      );
    };
}
