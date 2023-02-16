{
  inputs,
  colorscheme,
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

    inputs.hyprland-contrib.packages.x86_64-linux.grimblast
    brightnessctl
    pamixer
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = import ./config.nix {inherit colorscheme;};
  };
}
