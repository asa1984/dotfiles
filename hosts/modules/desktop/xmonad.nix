{
  services.xserver = {
    enable = true;
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };

    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };
  };
}
