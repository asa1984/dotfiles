{
  user,
  stateVersion,
  system,
  nixpkgs,
  home-manager,
  ...
}: let
  home-profile = import ./home.nix;
in {
  nixos = home-profile {
    profilePath = ./profiles/desktop.nix;
    inherit user stateVersion system nixpkgs home-manager;
  };
  laptop-gnome = home-profile {
    profilePath = ./profiles/laptop-gnome.nix;
    inherit user stateVersion system nixpkgs home-manager;
  };
}
