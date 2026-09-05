inputs:
let
  defaultOverlays = [
    inputs.self.overlays.default
    inputs.fenix.overlays.default
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
      ]
      ++ [ inputs.self.darwinModules.default ]
      ++ modules;
    };
}
