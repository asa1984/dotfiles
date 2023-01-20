{ user, stateVersion, pkgs, ... }:
let
  home-common = {
    home = {
      username = user;
      homeDirectory = "/home/${user}";
    };
  };
in
{
  nixos = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      home-common
      import
      ./profiles/desktop.nix
    ];
  };
}
