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
  ];

  home.packages = with pkgs; [
    wofi
    wofi-emoji
    wtype
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = import ./config.nix {inherit colorscheme;};
  };
}
