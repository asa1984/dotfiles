{pkgs, ...}: let
  # TODO: add a way to change the wallpaper
  wallpaper = "silent-sea";
in {
  imports = [
    ./rofi
    ./dunst.nix
  ];

  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./config.hs;
      extraPackages = haskellPackages:
        with haskellPackages; [xmonad-contrib xmonad-extras];
    };
  };

  home.packages = with pkgs; [
    feh
  ];

  home.file."wallpaper.jpg" = {
    target = "Wallpapers/wallpaper.jpg";
    source = ./Wallpapers/${wallpaper}.jpg;
  };
}
