{ lib, user, stateVersion, nixpkgs, home-manager, hyprland, xremap-flake, ... }:
let
  system = "x86_84-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow proprietary software
  };
in
{
  # Desktop on my home profile
  desktop_home = lib.nixosSystem
    {
      inherit system;
      specialArgs = { inherit user; inherit stateVersion; };
      modules = [
        ./profiles/desktop_home
        ./system.nix
        hyprland.nixosModules.default
        xremap-flake.nixosModules.default
      ];
    };

  # HP laptop profile
  # laptop_hp = lib.nixosSystem {};

  # ROG laptop profile
  # laptop_rog = lib.nixosSystem {};
}
