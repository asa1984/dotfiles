{
  services.picom = {
    enable = true;
    wintypes = { dock = { shadow = false; }; };
    settings = {
      backend = "glx";
      glx-no-stencil = true;
      glx-copy-from-front = false;

      # Opacity
      active-opacity = 1;
      inactive-opacity = 1;
      frame-opacity = 1;
      inactive-opacity-override = false;

      # Blur
      blur-background = true;
      blur-method = "dual_kawase";
      blur-strength = 6;

      blur-background-exclude = [
        "class_g = 'slop'" # Disable blur for screenshot tool
      ];

      # Corners
      corner-radius = 16;
      round-borders = 1;
      rounded-corners-exclude = [
        "class_g = 'Rofi'"
        "class_g = 'Dunst'"
        "widthb>1900 && height>1000" # Disable corner radius when fullscreen
      ];

      # Fading
      fading = true;
      fade-delta = 1;
      fade-in-step = 1.0e-2;
      fade-out-step = 1.0e-2;
      no-fading-openclose = false;

      # Shadow
      shadow = true;
      shadow-radius = 12;
      shadow-offset-x = -5;
      shadow-offset-y = -5;
      shadow-opacity = 0.2;

      # Other
      mark-wmwin-focused = true;
      mark-ovredir-focused = false;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      vsync = true;
      dbe = false;
      unredir-if-possible = false;
      focus-exclude = [ ];
      detect-transient = true;
      detect-client-leader = true;
      xrender-sync-fence = true;
    };
  };
}
