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

    inputs.hyprland-contrib.packages.x86_64-linux.grimblast
    brightnessctl
    pamixer
  ];
  home.file = {
    ".config/hypr/hyprland.conf".text = import ./config.nix {inherit colorscheme;};
    ".config/wofi/style.css".text = builtins.readFile ./wofi.css;
  };
}
