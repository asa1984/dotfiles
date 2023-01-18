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

        normal.family = "HackGen35 Console NFJ";
      };

    };
  };
}
