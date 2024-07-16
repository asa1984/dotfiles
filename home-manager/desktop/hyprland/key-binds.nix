{ pkgs, ... }:
let
  ws-switch =
    pkgs.writeScriptBin "ws-switch"
      # bash
      ''
        monitor=$(hyprctl activeworkspace -j | jq .monitorID)
        hyprctl dispatch workspace $(($monitor * 10 + $1))
      '';
  ws-move =
    pkgs.writeScriptBin "ws-move"
      # bash
      ''
        monitor=$(hyprctl activeworkspace -j | jq .monitorID)
        hyprctl dispatch movetoworkspace $(($monitor * 10 + $1))
      '';

  toggle-monitor =
    pkgs.writeScriptBin "toggle-monitor"
      # bash
      ''
        hyprctl monitors -j | jq 'map(select(.focused|not).activeWorkspace.id)[0]' | xargs hyprctl dispatch workspace
      '';

  better-movefocus =
    pkgs.writeScriptBin "better-movefocus"
      # bash
      ''
        if [ "$(hyprctl activewindow -j | jq .fullscreen)" = "true" ]; then
          hyprctl monitors -j | jq 'map(select(.focused|not).activeWorkspace.id)[0]' | xargs hyprctl dispatch workspace
        else
          hyprctl dispatch movefocus $1
        fi
      '';

  open-terminal =
    pkgs.writeScriptBin "open-terminal"
      # bash
      ''
        window_count=$(hyprctl activeworkspace -j | jq .windows)
        is_fullscreen=$(hyprctl activeworkspace -j | jq .hasfullscreen)

        hyprctl dispatch exec wezterm

        if [ "$window_count" -eq 0 ] && [ "$is_fullscreen" = "false" ]; then
          sleep 0.1
          hyprctl dispatch fullscreen
        elif [ "$window_count" -ge 1 ] && [ "$is_fullscreen" = "true" ]; then
          hyprctl dispatch fullscreen
        fi
      '';

  open-wofi =
    pkgs.writeScriptBin "open-wofi"
      # bash
      ''
        window_count=$(hyprctl activeworkspace -j | jq .windows)
        is_fullscreen=$(hyprctl activeworkspace -j | jq .hasfullscreen)

        wofi --show drun --width 512px

        if [ "$window_count" -eq 0 ] && [ "$is_fullscreen" = "false" ]; then
          sleep 0.1
          hyprctl dispatch fullscreen
        elif [ "$window_count" -ge 1 ] && [ "$is_fullscreen" = "true" ]; then
          hyprctl dispatch fullscreen
        fi
      '';

  close-window =
    pkgs.writeScriptBin "close-window"
      # bash
      ''
        hyprctl dispatch killactive
        sleep 0.01

        window_count=$(hyprctl activeworkspace -j | jq .windows)
        is_fullscreen=$(hyprctl activeworkspace -j | jq .hasfullscreen)
        if [ "$window_count" -eq 1 ] && [ "$is_fullscreen" = "false" ]; then
          hyprctl dispatch fullscreen
        elif [ "$window_count" -gt 1 ] && [ "$is_fullscreen" = "true" ]; then
          hyprctl dispatch fullscreen
        fi
      '';

in
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$subMod" = "ALT";
    "$term" = "wezterm";
    bind = [
      "$mainMod, Return, exec, ${open-terminal}/bin/open-terminal"
      "$mainMod SHIFT, Q, exec, ${close-window}/bin/close-window"
      "$mainMod SHIFT, M, exit"
      "$mainMod, F, fullscreen"
      "$mainMod SHIFT, F, togglefloating"

      # move focus
      "$mainMod, left, exec, ${better-movefocus}/bin/better-movefocus l"
      "$mainMod, down, exec, ${better-movefocus}/bin/better-movefocus d"
      "$mainMod, up, exec, ${better-movefocus}/bin/better-movefocus u"
      "$mainMod, right, exec, ${better-movefocus}/bin/better-movefocus r"
      "$subMod, Tab, cyclenext"
      "$subMod SHIFT, Tab, cyclenext, prev"

      # switch workspace
      "$mainMod, 1, exec, ${ws-switch}/bin/ws-switch 1"
      "$mainMod, 2, exec, ${ws-switch}/bin/ws-switch 2"
      "$mainMod, 3, exec, ${ws-switch}/bin/ws-switch 3"
      "$mainMod, 4, exec, ${ws-switch}/bin/ws-switch 4"
      "$mainMod, 5, exec, ${ws-switch}/bin/ws-switch 5"
      "$mainMod, 6, exec, ${ws-switch}/bin/ws-switch 6"
      "$mainMod, 7, exec, ${ws-switch}/bin/ws-switch 7"
      "$mainMod, 8, exec, ${ws-switch}/bin/ws-switch 8"
      "$mainMod, 9, exec, ${ws-switch}/bin/ws-switch 9"
      "$mainMod, 0, exec, ${ws-switch}/bin/ws-switch 10"
      "$mainMod CTRL, right, workspace, m+1"
      "$mainMod CTRL, left, workspace, m-1"
      "$mainMod, mouse_down, workspace, m+1"
      "$mainMod, mouse_up, workspace, m-1"

      # move window to workspace
      "$mainMod SHIFT, 1, exec, ${ws-move}/bin/ws-move 1"
      "$mainMod SHIFT, 2, exec, ${ws-move}/bin/ws-move 2"
      "$mainMod SHIFT, 3, exec, ${ws-move}/bin/ws-move 3"
      "$mainMod SHIFT, 4, exec, ${ws-move}/bin/ws-move 4"
      "$mainMod SHIFT, 5, exec, ${ws-move}/bin/ws-move 5"
      "$mainMod SHIFT, 6, exec, ${ws-move}/bin/ws-move 6"
      "$mainMod SHIFT, 7, exec, ${ws-move}/bin/ws-move 7"
      "$mainMod SHIFT, 8, exec, ${ws-move}/bin/ws-move 8"
      "$mainMod SHIFT, 9, exec, ${ws-move}/bin/ws-move 9"
      "$mainMod SHIFT, 0, exec, ${ws-move}/bin/ws-move 10"
      "$mainMod SHIFT, right, movetoworkspace, m+1"
      "$mainMod SHIFT, left, movetoworkspace, m-1"

      # toggle monitor
      "$mainMod, Tab, exec, ${toggle-monitor}/bin/toggle-monitor"

      # screenshot
      ", Print, exec, grimblast --notify copy output"
      ''$mainMod, Print, exec, grimblast --notify copysave output "$HOME/Screenshots/$(date +%Y-%m-%dT%H:%M:%S).png"''
      ''$mainMod SHIFT, s, exec, grimblast --notify copysave area "$HOME/Screenshots/$(date +%Y-%m-%dT%H:%M:%S).png"''

      # launcher
      "$mainMod, s, exec, ${open-wofi}/bin/open-wofi"
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
