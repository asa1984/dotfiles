{ user, ... }:
{
  imports = [
    ../../modules/shell
    ../../modules/git
    ../../modules/nvim
    ../../modules/tools
    ../../modules/alacritty
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
