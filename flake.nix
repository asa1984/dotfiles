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
          _module.args = {
            colorscheme = import ./colorschemes/dracula.nix;
          };

          nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "slack"
            "discord"
            "brave"
            "parsec-bin"
            "vscode"
          ];

          programs.home-manager.enable = true;
          home.stateVersion = "22.11";
          imports = [
            ./modules/fonts.nix
            ./modules/git
            ./modules/nvim
	    ./modules/shell
            ./modules/tools
            ./modules/development
            ./modules/virtualization
          ];
        };

      home-linux = {
        home.homeDirectory = "/home/asahi";
        home.username = "asahi";
        imports = [
          ./modules/applications
        ];
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
