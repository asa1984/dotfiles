{
  description = "Homa manager flake of ASA1984";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      home-common = { lib, ... }:
        {
          programs.home-manager.enable = true;
          home.stateVersion = "22.11";
          imports = [
            ./modules/fonts.nix
            ./modules/zsh
            ./modules/git
          ];
        };

      home-linux = {
        home.homeDirectory = "/home/asahi";
        home.username = "asahi";
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./system/configuration.nix ];
      };

      homeConfigurations = {
        nixos = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            home-common
            home-linux
          ];
        };
      };
    };
}
