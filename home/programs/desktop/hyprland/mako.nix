{colorscheme, ...}: let
  inherit (colorscheme) hashrgb;
in {
  programs.mako = {
    enable = true;
    defaultTimeout = 5000;
    font = "HackGen35 Console NFJ";
    borderRadius = 8;
    borderSize = 0;

    backgroundColor = hashrgb.bg;
  };
}
