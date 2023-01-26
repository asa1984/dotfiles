{
  description = "NixOS & homa-manager flake of ASA1984";

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
    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , home-manager
    , hyprland
    , kmonad
    , ...
    }:
    {
      nixosConfigurations = {
        # Desktop
        prime = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/prime ];
        };
        # HP Laptop
        # envy13 = nixpkgs.lib.nixosSystem {
        #   specialArgs = { inherit inputs; };
        #   modules = [ ./hosts/envy13 ];
        # };
      };

      homeConfigurations = {
        # Desktop
        "asahi@prime" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [
            hyprland.homeManagerModules.default
            ./home/prime.nix
          ];
        };
        # HP Laptop
        # "asahi@envy13" = home-manager.lib.homeManagerConfiguration {
        #   pkgs = import nixpkgs {
        #     system = "x86_64-linux";
        #     config.allowUnfree = true;
        #   };
        #   extraSpecialArgs = { inherit inputs; };
        #   modules = [ ./home/envy13.nix ];
        # };
      };
    };
}
