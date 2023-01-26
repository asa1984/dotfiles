{pkgs, ...}: {
  home.packages = with pkgs; [xdg-utils];

  xdg.enable = true;
  gtk.enable = true;
}
