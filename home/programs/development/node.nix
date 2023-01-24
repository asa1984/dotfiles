{pkgs, ...}: {
  # pkgsの順番に注意
  home.packages = with pkgs; [nodePackages.npm nodejs yarn];
}
