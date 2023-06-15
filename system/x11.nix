{pkgs, ...}: {
  services.xserver = {
    enable = true;
    autoRepeatDelay = 300;
    autoRepeatInterval = 30;
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };

    displayManager.defaultSession = "home-manager";

    desktopManager = {
      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };
  };
}
