{
  services.xserver = {
    enable = true;
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };
  };
}
