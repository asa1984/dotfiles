{ user, ... }:
{
  imports = [
    ../../modules/shell
    ../../modules/git
    ../../modules/editors
    ../../modules/tools
    ../../modules/applications
  ];
  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };
  # manage itself
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
}
