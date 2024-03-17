{ theme, ... }:
with theme.xcolors; {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        timeout = 30;
        background = bg;
        frame_color = blue;
        corner_radius = 12;
        font = "Noto Sans CJK JP";
      };

      urgency_low = {
        background = bg;
        foreground = fg;
      };
      urgency_normal = {
        background = bg;
        foreground = fg;
      };
      urgency_critical = {
        background = bg;
        foreground = fg;
        frame_color = red;
      };
    };
  };
}
