{ pkgs, inputs, ... }:
{
  imports = [
    ./settings.nix
    ./key-binds.nix
    ./wofi.nix
    ./dunst.nix
    ./swaylock.nix
  ];

  wayland.windowManager.hyprland.enable = true;

  home.packages =
    (with pkgs; [
      brightnessctl # screen brightness
      grimblast # screenshot
      hypr-helper # my hyprland helper tool
      hyprpicker # color picker
      pamixer # pulseaudio mixer
      playerctl # media player control
      swww # wallpaper
      wayvnc # vnc server
      wev # key event watcher
      wf-recorder # screen recorder
      wl-clipboard # clipboard manager
    ])
    ++ [
      inputs.hyprsome.packages.${pkgs.system}.default # workspace manager
    ];

  home.file = {
    "sea.jpg" = {
      target = ".config/hypr/wallpaper/sea.jpg";
      source = pkgs.fetchurl {
        url = "https://i.redd.it/49mj5c88ndla1.jpg";
        sha256 = "sha256-idMl5YkMMrXfBW36eG0buuJZ1IjmZLG/5TwfVROmC2s=";
      };
    };
    "talos-2.jpg" = {
      target = ".config/hypr/wallpaper/talos-2.jpg";
      source = pkgs.fetchurl {
        url = "https://web-static.hg-cdn.com/endfield/official/oversea/_next/static/media/02_HD.f591bfa9.jpg";
        sha256 = "sha256-sUo9db8qeo5jO9H28L8IhZFrW0MKevZh54B9N5Wcg/Y=";
      };
    };
  };
}
