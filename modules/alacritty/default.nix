{ colorscheme, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 5; y = 5; };
      };

      font = {
        size = 12;

        normal.family = "HackGen Console NF";
      };

      colors = {
        primary = {
          background = colorscheme.bg-primary;
          foreground = colorscheme.fg-primary;
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
