{ user, pkgs, ... }:
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
  home.packages = with pkgs; [ deno nixpkgs-fmt ];
  home.stateVersion = "22.11";
}
