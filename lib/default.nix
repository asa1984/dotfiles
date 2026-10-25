inputs:
let
  inherit (inputs.nixpkgs) lib;

  defaultOverlays = [
    inputs.self.overlays.bumps
    inputs.self.overlays.default
    inputs.llm-agents.overlays.shared-nixpkgs
  ];
in
{
  makeDarwinConfig =
    {
      hostname, # String
      modules, # List<Module>
      overlays ? defaultOverlays, # List<Overlay> | null
      system, # "x86_64-darwin" | "aarch64-darwin"
      theme, # String
      username, # String
      extraSpecialArgs ? { }, # AttrSet
    }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = extraSpecialArgs // {
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
      ]
      ++ [ inputs.self.darwinModules.default ]
      ++ modules;
    };

  # dir 直下のモジュールを { <name> = <path>; } にする (foo.nix と foo/ はどちらも foo)。
  # configs/ を他の flake から import できるように export するのに使う。
  modulesIn =
    dir: # Path
    lib.mapAttrs' (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (dir + "/${name}")) (
      builtins.readDir dir
    );
}
