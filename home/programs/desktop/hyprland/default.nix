{
  inputs,
  colorscheme,
  pkgs,
  ...
}: {
  imports = [
    ../common
    ./eww
    ./mako.nix
  ];

  home.packages = with pkgs; [
    wofi
    wofi-emoji
    wtype
    wev

    swaybg
    swayidle
    swaylock

    inputs.hyprland-contrib.packages.x86_64-linux.grimblast
    brightnessctl
    pamixer
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = (import ./hypr-config.nix) colorscheme;
    ".config/hypr/wallpapers".source = ./wallpapers;
    ".config/wofi/style.css".text = (import ./wofi-style.nix) colorscheme;
  };
}
