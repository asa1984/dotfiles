{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$subMod" = "ALT";
    "$term" = "wezterm";
    bind = [
      "$mainMod, Return, exec, $term"
      "$mainMod SHIFT, Q, killactive"
      "$mainMod SHIFT, M, exit"
      "$mainMod, F, fullscreen"
      "$mainMod SHIFT, F, togglefloating"

      # move focus
      "$mainMod, left, exec, hypr-helper movefocus left"
      "$mainMod, down, exec, hypr-helper movefocus down"
      "$mainMod, up, exec, hypr-helper movefocus up"
      "$mainMod, right, exec, hypr-helper movefocus right"
      "$mainMod, h, movefocus, l"
      "$mainMod, j, movefocus, d"
      "$mainMod, k, movefocus, u"
      "$mainMod, l, movefocus, r"
      "$subMod, Tab, cyclenext"
      "$subMod SHIFT, Tab, cyclenext, prev"

      # switch workspace
      "$mainMod, 1, exec, hyprsome workspace 1"
      "$mainMod, 2, exec, hyprsome workspace 2"
      "$mainMod, 3, exec, hyprsome workspace 3"
      "$mainMod, 4, exec, hyprsome workspace 4"
      "$mainMod, 5, exec, hyprsome workspace 5"
      "$mainMod, 6, exec, hyprsome workspace 6"
      "$mainMod, 7, exec, hyprsome workspace 7"
      "$mainMod, 8, exec, hyprsome workspace 8"
      "$mainMod, 9, exec, hyprsome workspace 9"
      "$mainMod, 0, exec, hyprsome workspace 10"
      "$mainMod CTRL, right, workspace, m+1"
      "$mainMod CTRL, left, workspace, m-1"
      "$mainMod, mouse_down, workspace, m+1"
      "$mainMod, mouse_up, workspace, m-1"

      # move window to workspace
      "$mainMod SHIFT, 1, exec, hyprsome move 1"
      "$mainMod SHIFT, 2, exec, hyprsome move 2"
      "$mainMod SHIFT, 3, exec, hyprsome move 3"
      "$mainMod SHIFT, 4, exec, hyprsome move 4"
      "$mainMod SHIFT, 5, exec, hyprsome move 5"
      "$mainMod SHIFT, 6, exec, hyprsome move 6"
      "$mainMod SHIFT, 7, exec, hyprsome move 7"
      "$mainMod SHIFT, 8, exec, hyprsome move 8"
      "$mainMod SHIFT, 9, exec, hyprsome move 9"
      "$mainMod SHIFT, 0, exec, hyprsome move 10"
      "$mainMod SHIFT, right, movetoworkspace, m+1"
      "$mainMod SHIFT, left, movetoworkspace, m-1"

      # toggle monitor
      "$mainMod, Tab, exec, hyprctl monitors -j|jq 'map(select(.focused|not).activeWorkspace.id)[0]'|xargs hyprctl dispatch workspace"

      # screenshot
      ", Print, exec, grimblast --notify copy output"
      ''
        $mainMod, Print, exec, grimblast --notify copysave output "$HOME/Screenshots/$(date +%Y-%m-%dT%H:%M:%S).png"''
      ''
        $mainMod SHIFT, s, exec, grimblast --notify copysave area "$HOME/Screenshots/$(date +%Y-%m-%dT%H:%M:%S).png"''

      # launcher
      "$mainMod, s, exec, wofi --show drun --width 512px"
      "$mainMod, period, exec, wofi-emoji"

      # color picker
      "$mainMod SHIFT, c, exec, hyprpicker --autocopy"

      # screen lock
      "$mainMod, l, exec, swaylock --image ~/.config/hypr/wallpaper/talos-2.jpg"

      # system
      "$mainMod, x, exec, systemctl suspend"
    ];
    bindm = [
      # move/resize window
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
    bindl = [
      # media control
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"

      # volume control: mute
      ", XF86AudioMute, exec, pamixer -t"
    ];
    bindle = [
      # volume control
      ", XF86AudioRaiseVolume, exec, pamixer -i 10"
      ", XF86AudioLowerVolume, exec, pamixer -d 10"

      # brightness control
      ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
      ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
    ];
  };
}
