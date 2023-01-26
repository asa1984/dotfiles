{pkgs, ...}: {
  imports = [../share ./waybar];

  home.packages = with pkgs; [
    mako
    wofi
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = builtins.readFile ./hyprland.conf;
  };
}
