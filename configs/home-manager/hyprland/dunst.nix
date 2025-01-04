{ theme, ... }:
{
  services.dunst = {
    enable = true;
    settings = with theme.xcolors; {
      global = {
        monitor = 1;
        timeout = 10;
        offset = "30x30";
        transparency = 10;
        foreground = fg;
        background = black;
        frame_color = black;
        corner_radius = 10;
        font = "Noto Sans CJK JP";
      };
      urgency_critical = {
        frame_color = red;
      };
    };
  };
}
