inputs:
let
  mkNixosSystem =
    {
      system,
      hostname,
      username,
      modules,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = {
        inherit inputs hostname username;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      };
    };

  mkHomeManagerConfiguration =
    {
      system,
      username,
      overlays,
      modules,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;

          # FIX: How to solve this?
          permittedInsecurePackages = [ "electron-25.9.0" ];
        };
      };
      extraSpecialArgs = {
        inherit inputs username;
        theme = (import ../themes) "tokyonight-moon";
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system overlays;
          config = {
            allowUnfree = true;
          };
        };
      };
      modules = modules ++ [
        {
          home = {
            inherit username;
            homeDirectory = "/home/${username}";
            stateVersion = "22.11";
            enableNixpkgsReleaseCheck = false;
          };
          programs.home-manager.enable = true;
          programs.git.enable = true;
        }
      ];
    };
in
{
  nixos = {
    terra = mkNixosSystem {
      system = "x86_64-linux";
      hostname = "terra";
      username = "asahi";
      modules = [ ./terra/nixos.nix ];
    };
    rhodes = mkNixosSystem {
      system = "x86_64-linux";
      hostname = "rhodes";
      username = "asahi";
      modules = [ ./rhodes/nixos.nix ];
    };
    rhine = mkNixosSystem {
      system = "x86_64-linux";
      hostname = "rhine";
      username = "asahi";
      modules = [ ./rhine/nixos.nix ];
    };
  };

  home-manager = {
    "asahi@terra" = mkHomeManagerConfiguration {
      system = "x86_64-linux";
      username = "asahi";
      overlays = [ inputs.fenix.overlays.default ];
      modules = [ ./terra/home-manager.nix ];
    };
    "asahi@rhodes" = mkHomeManagerConfiguration {
      system = "x86_64-linux";
      username = "asahi";
      overlays = [ inputs.fenix.overlays.default ];
      modules = [ ./rhodes/home-manager.nix ];
    };
    "asahi@rhine" = mkHomeManagerConfiguration {
      system = "x86_64-linux";
      username = "asahi";
      overlays = [ inputs.fenix.overlays.default ];
      modules = [ ./rhine/home-manager.nix ];
    };
  };
}
