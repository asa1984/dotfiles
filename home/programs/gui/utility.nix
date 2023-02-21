{pkgs, ...}: {
  home.packages = with pkgs; [
    # GUI File Manager
    xfce.thunar
  ];
}
