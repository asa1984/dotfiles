{
  colorscheme,
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
    wofi-emoji
    wtype
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    disableAutoreload = true;
    extraConfig = import ./config.nix {inherit colorscheme;};
  };
}
