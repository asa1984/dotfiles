{
  pkgs,
  inputs,
  ...
}: let
  hypr-helper = pkgs.callPackage ./hypr-helper {};
in {
  imports = [
    ./wofi.nix
    ./dunst.nix
    ./settings.nix
    ./key-binds.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
  };

  home.packages =
    (with pkgs; [
      grimblast # screenshot
      wev # key event watcher
      wayvnc # vnc server
      wl-clipboard # clipboard manager
      wf-recorder # screen recorder
      brightnessctl # screen brightness
      pamixer # pulseaudio mixer
      playerctl # media player control
      swww # wallpaper
    ])
    ++ [
      inputs.hyprpicker.packages.${pkgs.system}.default # color picker
      inputs.hyprpaper.packages.${pkgs.system}.default # wallpaper
      inputs.hyprsome.packages.${pkgs.system}.default # workspace manager
      hypr-helper # my hyprland helper tool
    ];
  # home.file = {
  #   "wallpaper.jpg" = {
  #     target = ".config/hypr/wallpaper/wallpaper.jpg";
  #     source = pkgs.fetchurl {
  #       url = "https://i.redd.it/49mj5c88ndla1.jpg";
  #       sha256 = "sha256-idMl5YkMMrXfBW36eG0buuJZ1IjmZLG/5TwfVROmC2s=";
  #     };
  #   };
  # };
}
