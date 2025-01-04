{ config, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = !config.services.xserver.enable; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };
}
