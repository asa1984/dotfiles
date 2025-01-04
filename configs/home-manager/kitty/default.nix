{
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_moon";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      cursor_blink_interval = 0; # Disable blinking cursor
      tab_bar_edge = "top";
      tab_bar_style = "separator";
      tab_separator = ''"┃"'';
      tab_title_max_length = 30;
      tab_title_template = ''" {title} "'';
      window_margin_width = "5 10";
      enable_audio_bell = false;
    };
  };
}
