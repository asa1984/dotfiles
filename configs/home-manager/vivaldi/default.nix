{ pkgs, ... }:
{
  programs.vivaldi = {
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
}
