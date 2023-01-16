{ user, ... }:
{
  imports = [
    ../../modules/shell
    ../../modules/tools
  ];
  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };
  # manage itself
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
}
