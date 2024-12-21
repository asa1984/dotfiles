{
  pkgs,
  private-modules,
  username,
  ...
}:
{
  imports = [
    ../../home-manager/cli
    ../../home-manager/gui/terminals/wezterm
    ../../modules/home-manager
    private-modules.hmModules.gaul
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
    enableNixpkgsReleaseCheck = false;
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;
  services.colima.enable = true;
  services.keybase-service.enable = true;

  programs.google-chrome.enable = true;
  services.raycast.enable = true;

  home.packages = with pkgs; [
    arc-browser
    keybase
    vscode
  ];
}
