{colorscheme, ...}: let
  inherit (colorscheme) hashrgb;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
      };

      font = {
        size = 12;
        normal.family = "JetBrainsMono Nerd Font";
      };

      colors = {
        primary = {
          background = hashrgb.bg;
          foreground = hashrgb.fg;
        };
        normal = {
          inherit (hashrgb) black;
          inherit (hashrgb) red;
          inherit (hashrgb) green;
          inherit (hashrgb) yellow;
          inherit (hashrgb) blue;
          inherit (hashrgb) magenta;
          inherit (hashrgb) cyan;
          inherit (hashrgb) white;
        };
      };
    };
  };
}
