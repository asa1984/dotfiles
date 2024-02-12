{
  imports = [
    ./fcitx5.nix
    ./fonts.nix
    ./security.nix
    ./sound.nix
    ./xremap.nix
  ];

  programs = {
    dconf.enable = true;
  };
  xdg.portal.enable = true;
}
