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

  programs.dconf.enable = true;
  security.polkit.enable = true;

  # Some applications (e.g. VSCode) require gnome-keyring for storing authentication credentials.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
  };
}
