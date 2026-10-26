let
  dotfilesOverlays = import ../overlays;
in
{
  makeDarwinConfig =
    {
      inputs, # AttrSet: inputs of the host's flake
      hostname, # String
      modules, # List<Module>
      overlays ? [
        dotfilesOverlays.bumps
        dotfilesOverlays.default
        inputs.llm-agents.overlays.shared-nixpkgs
      ], # List<Overlay> | null
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
      ++ [ ../modules/nix-darwin ]
      ++ modules;
    };
}
