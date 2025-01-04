{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ../../modules/home-manager

    inputs.private-modules.hmModules.gaul
    ../../configs/home-manager/cli-utilities
    ../../configs/home-manager/direnv
    ../../configs/home-manager/gh
    ../../configs/home-manager/git
    ../../configs/home-manager/lazygit
    ../../configs/home-manager/neovim
    ../../configs/home-manager/starship
    ../../configs/home-manager/wezterm
    ../../configs/home-manager/zsh
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
    enableNixpkgsReleaseCheck = false;
  };

  development.enable = true;

  home.packages = with pkgs; [
    arc-browser
    keybase
    vscode
  ];

  programs.home-manager.enable = true;

  # Development
  programs.git.enable = true;
  services.colima.enable = true;
  services.keybase-service.enable = true;

  # GUI
  programs.google-chrome.enable = true;
  services.raycast.enable = true;
}
