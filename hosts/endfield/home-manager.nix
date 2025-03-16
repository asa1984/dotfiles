{
  pkgs,
  username,
  ...
}:
{
  imports = [
    ../../modules/home-manager

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
    _1password-cli
    vscode
  ];

  programs.home-manager.enable = true;

  # Development
  programs.git.enable = true;

  # GUI
  programs.google-chrome.enable = true;
  services.raycast.enable = true;
}
