{ pkgs, ... }: {
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
    };
  };
}
