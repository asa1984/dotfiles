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
    ./wofi.nix
  ];

  programs = {
    zsh.loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland &> /dev/null
      fi
    '';
  };

  home.packages = with pkgs; [
    # Wayland utility
    wtype
    wev
    wayvnc

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
    ".config/hypr/wallpaper.jpg".source = ./wallpapers/silent-sea.jpg;
  };
}
