{ profilePath
, user
, stateVersion
, system
, nixpkgs
, home-manager
, ...
}:
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
  # Allow proprietary software
  # Watch home-manager issue#2942
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  extraSpecialArgs = { inherit user stateVersion; };
  modules = [
    home-common
    {
      imports = [
        profilePath
      ];
    }
  ];
}
