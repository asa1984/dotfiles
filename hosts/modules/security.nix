{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    swaylock = {};
    login.enableGnomeKeyring = true;
  };
}
