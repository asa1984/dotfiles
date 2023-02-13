{
  services = {
    flatpak.enable = true;

    gnome.gnome-keyring.enable = true;
  };
  security.pam.services.login.enableGnomeKeyring = true;
}
