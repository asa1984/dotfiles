{
  lib,
  user,
  stateVersion,
  system,
  nixpkgs,
  hyprland,
  xremap-flake,
  ...
}: let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow proprietary software
  };
in {
  # Desktop on my home profile
  desktop_home = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit user stateVersion;};
    modules = [
      ./profiles/desktop_home
      ./configuration.nix
      hyprland.nixosModules.default
      xremap-flake.nixosModules.default
    ];
  };

  # HP laptop profile
  laptop_hp = lib.nixosSystem {
    inherit system;
    specialArgs = {inherit user stateVersion;};
    modules = [
      ./profiles/laptop_hp
      ./configuration.nix
      xremap-flake.nixosModules.default
    ];
  };

  # ROG laptop profile
  # laptop_rog = lib.nixosSystem {};
}
