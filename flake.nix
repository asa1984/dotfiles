{
  description = "NixOS & homa-manager flake of ASA1984";

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    kmonad,
    ...
  }: let
    utils = import ./utils {inherit utils;};
    inherit (utils) mkSystem mkHome;
  in {
    nixosConfigurations = {
      # Desktop
      prime = mkSystem {
        hostname = "prime";
        pkgs = import {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      # HP Laptop
      envy13 = mkSystem {
        hostname = "envy13";
        pkgs = import {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };

    homeConfigurations = {
      # Desktop
      "asahi@prime" = mkHome {
        username = "asahi";
        hostname = "prime";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        features = [
          "desktop/hyprland"
        ];
      };
      # HP Laptop
      "asahi@envy13" = mkHome {
        username = "asahi";
        hostname = "envy13";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        features = [
          "desktop/gnome"
        ];
      };
    };
  };
}
