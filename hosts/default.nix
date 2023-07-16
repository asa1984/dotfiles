inputs:
let
  mkNixosSystem =
    { system
    , hostname
    , username
    , modules
    ,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = {
        inherit inputs hostname username;
      };
    };

  mkHomeManagerConfiguration =
    { system
    , username
    , overlays
    , modules
    ,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit inputs username;
        theme = (import ../themes) "tokyonight-moon";
      };
      modules =
        modules
        ++ [
          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
              stateVersion = "22.11";
            };
            programs.home-manager.enable = true;
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
      modules = [
        ./terra/nixos.nix
      ];
    };
    rhodes = mkNixosSystem {
      system = "x86_64-linux";
      hostname = "rhodes";
      username = "asahi";
      modules = [
        ./rhodes/nixos.nix
      ];
    };
    rhine = mkNixosSystem {
      system = "x86_64-linux";
      hostname = "rhine";
      username = "asahi";
      modules = [
        ./rhine/nixos.nix
      ];
    };
  };

  home-manager = {
    "asahi@terra" = mkHomeManagerConfiguration {
      system = "x86_64-linux";
      username = "asahi";
      overlays = [ (import inputs.rust-overlay) ];
      modules = [
        ./terra/home-manager.nix
      ];
    };
    "asahi@rhodes" = mkHomeManagerConfiguration {
      system = "x86_64-linux";
      username = "asahi";
      overlays = [ (import inputs.rust-overlay) ];
      modules = [
        ./rhodes/home-manager.nix
      ];
    };
    "asahi@rhine" = mkHomeManagerConfiguration {
      system = "x86_64-linux";
      username = "asahi";
      overlays = [ (import inputs.rust-overlay) ];
      modules = [
        ./rhine/home-manager.nix
      ];
    };
  };
}
