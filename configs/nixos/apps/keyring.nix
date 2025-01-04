{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security = {
    polkit.enable = true;
    pam.services.login.enableGnomeKeyring = true;
  };
}
