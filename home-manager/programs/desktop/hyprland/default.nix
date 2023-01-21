{ pkgs, ... }: {
  imports = [ ./waybar ];

  home.packages = with pkgs;[
    mako
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = builtins.readFile ./hyprland.conf;
  };
}