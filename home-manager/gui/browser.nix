{ pkgs, ... }:
{
  programs = {
    firefox.enable = true;
    google-chrome.enable = true;
    vivaldi = {
      enable = true;
      package = pkgs.vivaldi.overrideAttrs {
        proprietaryCodecs = true;
        enableWidevine = true;
      };
      commandLineArgs = [
        "--enable-features=WebUIDarkMode"
        "--force-dark-mode"
      ];
    };
  };
}
