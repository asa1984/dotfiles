{ lib, user, stateVersion, pkgs, nixpkgs, home-manager, hyprland, xremap-flake, ... }:
{
  # Desktop on my home profile
  desktop_home = lib.nixosSystem
    {
      inherit system;
      specialArgs = { inherit user stateVersion; };
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
