{
  inputs,
  pkgs,
  ...
}: {
  imports = [../common ./waybar inputs.hyprland.homeManagerModules.default];

  home.packages = with pkgs; [
    mako
    wofi
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };
}
