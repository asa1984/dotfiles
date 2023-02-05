{pkgs, ...}: {
  # pkgsの順番に注意
  home.packages = with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    yarn
  ];
}
