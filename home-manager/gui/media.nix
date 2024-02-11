{pkgs, ...}: {
  home.packages = with pkgs; [
    spotify
    gnome.totem # video player
    gnome.evince # pdf viewer
  ];

  programs.ncspot.enable = true; # spotify tui
  services.easyeffects.enable = true;
  programs.obs-studio.enable = true;
}
