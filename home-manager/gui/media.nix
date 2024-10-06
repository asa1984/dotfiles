{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      totem # video player
      evince # pdf viewer
      spotify
    ]
  );

  programs.ncspot.enable = true; # spotify tui
  services.easyeffects.enable = true;
  programs.obs-studio.enable = true;
}
