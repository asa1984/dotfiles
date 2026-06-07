{
  system = {
    defaults = {
      CustomUserPreferences."com.apple.AppleMultitouchTrackpad".DragLock = true;
      dock = {
        autohide = true;
        largesize = 64;
        magnification = true;
        mineffect = "scale";
        show-recents = false;
        tilesize = 50;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false; # Enable key repeat on press-and-hold instead of accent menu
        "com.apple.keyboard.fnState" = true; # Use function keys as standard function keys
        "com.apple.swipescrolldirection" = false; # Disable natural scrolling
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
