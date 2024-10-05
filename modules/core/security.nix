{ pkgs, ... }:
{
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  security = {
    # allow members of the wheel group to run sudo without a password
    sudo.wheelNeedsPassword = false;
  };
}
