{pkgs, ...}: {
  xdg = {
    enable = true;
  };
  home.packages = with pkgs; [xdg-utils];
}
