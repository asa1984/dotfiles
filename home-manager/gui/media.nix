{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    gnome.totem # video player
    gnome.evince # pdf viewer
    spotify
    inputs.syndicationd.packages.${pkgs.system}.default
  ];

  programs.ncspot.enable = true; # spotify tui
  services.easyeffects.enable = true;
  programs.obs-studio.enable = true;
}
