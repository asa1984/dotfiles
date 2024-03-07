{
  lib,
  theme,
  ...
}: let
  colors = theme.colors;
in {
  wayland.windowManager.hyprland.settings = {
    env = [
      "GTK_IM_MODULE, fcitx"
      "QT_IM_MODULE, fcitx"
      "XMODIFIERS, @im=fcitx"
    ];
    exec-once = [
      "swww init && swww img ~/.config/hypr/wallpaper/sea.jpg"
      "fcitx5 -D"
      "hypr-helper start"
      "discord --start-minimized"
      "steam -silent"
    ];
    windowrule = [
      "pseudo, noblur, class:(fcitx)"
      "noblur, class:(wofi)"
    ];
    input = {
      repeat_delay = 300;
      repeat_rate = 30;
      follow_mouse = 1;
      sensitivity = lib.mkDefault (-0.5); # -1.0 - 1.0, 0 means no modification.
    };
    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 2;
      "col.inactive_border" = "rgb(${colors.bg})";
      "col.active_border" = "rgb(${colors.blue})";
      resize_on_border = true;
    };
    decoration = {
      rounding = 10;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        xray = true;
        ignore_opacity = true;
        new_optimizations = true;
      };
    };
    animations = {
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 4, myBezier, slide"
        "border, 1, 5, default"
        "fade, 1, 5, default"
        "workspaces, 1, 6, default"
      ];
    };
    dwindle = {
      pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = true; # you probably want this
    };
    misc = {
      disable_hyprland_logo = true;
    };
    master = {
      new_is_master = true;
    };
  };
}
