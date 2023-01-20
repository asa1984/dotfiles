{ user, stateVersion, pkgs, home-manager, ... }:
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
