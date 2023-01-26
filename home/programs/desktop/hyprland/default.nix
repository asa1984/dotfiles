{pkgs, ...}: {
  imports = [../common ./waybar];

  wayland.windowManager.hyprland.enable = true;
  home.packages = with pkgs; [
    mako
    wofi
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = builtins.readFile ./hyprland.conf;
  };
}
