{ pkgs, ... }:
{
  home.packages = (
    with pkgs;
    [
      evince # pdf viewer
      xfce.thunar # GUI file manager
      totem # video player
    ]
  );
}
