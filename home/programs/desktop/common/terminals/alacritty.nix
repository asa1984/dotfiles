{colorscheme, ...}: {
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
        normal.family = "HackGen35 Console NFJ";
      };

      colors = {
        primary = {
          background = colorscheme.bg;
          foreground = colorscheme.fg;
        };
        normal = {
          inherit (colorscheme) black;
          inherit (colorscheme) red;
          inherit (colorscheme) green;
          inherit (colorscheme) yellow;
          inherit (colorscheme) blue;
          inherit (colorscheme) magenta;
          inherit (colorscheme) cyan;
          inherit (colorscheme) white;
        };
      };
    };
  };
}
