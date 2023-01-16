{ lib, user, ... }:
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
      modules = [
        ./desktop_home
        ./system.nix
        hyprland.nixosModules.default
        {
          home-manager = {
            extraSpecialArgs = { inherit user; };
            users.${user} = {
              imports = [ (import ./desktop_home/home.nix) ];
            };
          };
        }
      ];
    };

  # HP laptop profile
  # TODO: replace old dotfiles of HP laptop
  # laptop_hp = lib.nixosSystem {};
}
