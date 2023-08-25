{pkgs, ...}: {
  imports = [
    ../../home-manager/cli
    ../../home-manager/desktop
    ../../home-manager/gui
  ];

  home.packages = with pkgs; [
    prismlauncher # alternative minecraft launcher
    jdk20
  ];
}
