{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 14;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Blue-Dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    # enable dark theme for all gtk applications
    # gtk2.extraConfig = ''
    #   gtk-application-prefer-dark-theme = true
    # '';
    # gtk3.extraConfig = {
    #   gtk-application-prefer-dark-theme = true;
    # };
    # gtk4.extraConfig = {
    #   gtk-application-prefer-dark-theme = true;
    # };
  };
}
