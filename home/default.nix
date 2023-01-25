{ username
, features
, ...
}: {
  imports =
    [
      ../programs/cli
    ]
    ++ builtins.filter builtins.pathExists (map (feature: ../programs/${feature}) features);

  programs = {
    home-manager.enable = true;
  };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
}
