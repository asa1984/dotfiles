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

        normal.family = "Hack Nerd Font Mono";
        normal.style = "Regular";
        bold.family = "Hack Nerd Font Mono";
        bold.style = "Bold";
        italic.family = "Hack Nerd Font Mono";
        italic.style = "Italic";
        bold_italic.family = "Hack Nerd Font Mono";
        bold_italic.style = "Bold Italic";
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
