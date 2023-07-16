{ pkgs, ... }: {
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    # enable dark theme for all gtk applications
    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = true
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
