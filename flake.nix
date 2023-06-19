{
  description = "NixOS & homa-manager flake of ASA1984";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Others
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: let
    colorscheme = (import ./colorschemes) "tokyonight-moon"; # to be removed
    theme = (import ./themes) "tokyonight-moon";
  in {
    nixosConfigurations = {
      # Desktop
      prime = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/prime ./system/xremap.nix];
      };
      # HP Laptop
      envy13 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/envy13 ./system/xremap.nix];
      };
      # Proxmox VE
      pve = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./hosts/pve];
      };
    };

    homeConfigurations = {
      # Desktop
      "asahi@prime" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [(import inputs.rust-overlay)];
        };
        extraSpecialArgs = {inherit inputs colorscheme theme;};
        modules = [./home/prime.nix];
      };
      # HP Laptop
      "asahi@envy13" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [(import inputs.rust-overlay)];
        };
        extraSpecialArgs = {inherit inputs colorscheme theme;};
        modules = [./home/envy13.nix];
      };
      # Proxmox VE
      "asahi@pve" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [(import inputs.rust-overlay)];
        };
        extraSpecialArgs = {inherit inputs colorscheme theme;};
        modules = [./home/pve.nix];
      };
    };

    formatter."x86_64-linux" = (import nixpkgs {system = "x86_64-linux";}).alejandra;
  };
}
