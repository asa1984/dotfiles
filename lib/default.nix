inputs:
let
  defaultOverlays = [
    inputs.self.overlays.default
    inputs.fenix.overlays.default
  ];
in
{
  makeNixosConfig =
    {
      hostname, # String
      modules, # List<Module>
      overlays ? defaultOverlays, # List<Overlay> | null
      system, # "x86_64-linux" | "aarch64-linux"
      username, # String
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          hostname
          inputs
          system
          username
          ;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        {
          nixpkgs = {
            inherit overlays;
            config.allowUnfree = true;
            hostPlatform = system;
          };
        }
      ] ++ [ inputs.self.nixosModules.default ] ++ modules;
    };

  makeHomeManagerConfig =
    {
      modules, # List<Module>
      overlays ? defaultOverlays, # List<Overlay> | null
      system, # "x86_64-linux" | "aarch64-linux" | "x86_64-darwin" | "aarch64-darwin"
      theme, # String
      username, # String
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit overlays system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit inputs system username;
        theme = (import ../themes) theme;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system overlays;
          config.allowUnfree = true;
        };
      };
      modules = [
        (
          { pkgs, ... }:
          {
            home = {
              inherit username;
              homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
              stateVersion = "24.11";
              enableNixpkgsReleaseCheck = false;
            };
            programs.home-manager.enable = true;
            programs.git.enable = true;
          }
        )
      ] ++ [ inputs.self.homeManagerModules.default ] ++ modules;
    };

  makeDarwinConfig =
    {
      hostname, # String
      modules, # List<Module>
      overlays ? defaultOverlays, # List<Overlay> | null
      system, # "x86_64-darwin" | "aarch64-darwin"
      theme, # String
      username, # String
    }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          hostname
          inputs
          system
          username
          ;
        theme = (import ../themes) theme;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        {
          nixpkgs = {
            inherit overlays;
            config.allowUnfree = true;
            hostPlatform = system;
          };
        }
      ] ++ [ inputs.self.darwinModules.default ] ++ modules;
    };
}
