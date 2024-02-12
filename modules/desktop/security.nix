{
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security = {
    polkit.enable = true;
    pam.services.login.enableGnomeKeyring = true;

    # wayland display lockers (e.g. swaylock) needs this
    pam.services.swaylock.text = "auth include login";
  };
}
