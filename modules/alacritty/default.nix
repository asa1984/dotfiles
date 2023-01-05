{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
  };

  padding = { x = 5; y = 5; };

  font = {
    size = 14;

    normal.family = "Hack Nerd Font Mono";
    normal.style = "Regular";
    bold.family = "Hack Nerd Font Mono";
    bold.style = "Bold";
    italic.family = "Hack Nerd Font Mono";
    italic.style = "Italic";
    bold_italic.family = "Hack Nerd Font Mono";
    bold_italic.style = "Bold Italic";
  };
}
