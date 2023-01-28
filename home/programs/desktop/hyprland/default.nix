{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../common
    ./waybar
    ./mako.nix
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    wofi
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };
}
