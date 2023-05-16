{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        timeout = 50;
        background = "#222436";
        frame_color = "#82aaff";
        corner_radius = 24;
        font = "HackGen35 Console NFJ";
      };

      urgency_low = {
        background = "#222436";
        foreground = "#c8d3f5";
      };
      urgency_normal = {
        background = "#222436";
        foreground = "#c8d3f5";
      };
      urgency_critical = {
        background = "#222436";
        foreground = "#c8d3f5";
        frame_color = "#ff757f";
      };
    };
  };
}
