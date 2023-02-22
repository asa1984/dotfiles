{
  inputs,
  colorscheme,
  pkgs,
  ...
}: {
  imports = [
    ./eww
    ./mako.nix
    ./swaylock.nix
  ];

  home.packages = with pkgs; [
    wofi
    wofi-emoji
    wtype
    wev

    swaybg
    swayidle

    inputs.hyprland-contrib.packages.x86_64-linux.grimblast
    inputs.hyprpicker.packages.x86_64-linux.hyprpicker
    wl-clipboard
    brightnessctl
    pamixer
    playerctl
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = (import ./hypr-config.nix) colorscheme;
    ".config/hypr/wallpapers".source = ./wallpapers;
    ".config/wofi/style.css".text = (import ./wofi-style.nix) colorscheme;
  };
}
