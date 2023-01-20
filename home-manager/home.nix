{ profilePath, user, stateVersion, pkgs, home-manager, ... }:
let
  home-common = {
    home = {
      username = user;
      homeDirectory = "/home/${user}";
      inherit stateVersion;
    };
    programs.home-manager.enable = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs =
    { inherit user stateVersion; };
  modules = [
    home-common
    {
      imports = [
        profilePath
      ];
    }
  ];
}
