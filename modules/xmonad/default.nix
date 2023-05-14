{
  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./config.hs;
      extraPackages = hp: with hp; [xmonad-contrib xmonad-extras];
    };
  };
}
