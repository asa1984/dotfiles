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
    #    xremap-flake.url="github:xremap/flake";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , home-manager
    , hyprland
    , #xremap,
      ...
    }:
    let
      user = "asahi";
    in
    {
      nixosConfigurations = (
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs user nixpkgs home-manager hyprland;
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
