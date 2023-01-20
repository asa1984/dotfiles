{ user, stateVersion, system, pkgs, nixpkgs, home-manager, ... }:
let
  home-profile = import ./home.nix;
in
{
  nixos = home-profile { profilePath = ./profiles/desktop.nix; inherit user stateVersion system pkgs nixpkgs home-manager; };
}
