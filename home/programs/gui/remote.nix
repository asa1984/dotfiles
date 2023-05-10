{pkgs, ...}: {
  home.packages = with pkgs; [parsec-bin remmina];
}
