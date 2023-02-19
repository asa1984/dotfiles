colorscheme: let
  inherit (colorscheme) colors;
in ''
  #----------#
  # Key Bind #
  #----------#
  $mainMod = SUPER
  $subMod = ALT

  bind = $mainMod, Return, exec, alacritty
  bind = $mainMod SHIFT, Q, killactive
  bind = $mainMod SHIFT, M, exit
  bind = $mainMod, F, fullscreen

  # Move focus with mainMod + arrow keys
  bind = $mainMod, left, movefocus, l
  bind = $mainMod, right, movefocus, r
  bind = $mainMod, up, movefocus, u
  bind = $mainMod, down, movefocus, d
  bind = $subMod, Tab, cyclenext
  bind = $subMod SHIFT, Tab, cyclenext, prev

  # Switch workspaces with mainMod + [0-9]
  bind = $mainMod, 1, workspace, 1
  bind = $mainMod, 2, workspace, 2
  bind = $mainMod, 3, workspace, 3
  bind = $mainMod, 4, workspace, 4
  bind = $mainMod, 5, workspace, 5
  bind = $mainMod, 6, workspace, 6
  bind = $mainMod, 7, workspace, 7
  bind = $mainMod, 8, workspace, 8
  bind = $mainMod, 9, workspace, 9
  bind = $mainMod, 0, workspace, 10

  # Move active window to a workspace with mainMod + SHIFT + [0-9]
  bind = $mainMod SHIFT, 1, movetoworkspace, 1
  bind = $mainMod SHIFT, 2, movetoworkspace, 2
  bind = $mainMod SHIFT, 3, movetoworkspace, 3
  bind = $mainMod SHIFT, 4, movetoworkspace, 4
  bind = $mainMod SHIFT, 5, movetoworkspace, 5
  bind = $mainMod SHIFT, 6, movetoworkspace, 6
  bind = $mainMod SHIFT, 7, movetoworkspace, 7
  bind = $mainMod SHIFT, 8, movetoworkspace, 8
  bind = $mainMod SHIFT, 9, movetoworkspace, 9
  bind = $mainMod SHIFT, 0, movetoworkspace, 10

  # Switch workspaces
  bind = $mainMod, mouse_down, workspace, e+1
  bind = $mainMod, mouse_up, workspace, e-1
  bind = $mainMod CTRL, right, workspace, e+1
  bind = $mainMod CTRL, left, workspace, e-1

  # Move/resize windows with mainMod + LMB/RMB and dragging
  bindm = $mainMod, mouse:272, movewindow
  bindm = $mainMod, mouse:273, resizewindow

  # Monitor backlight
  bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
  bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

  # Audio
  bind = , XF86AudioRaiseVolume, exec, pamixer -i 10
  bind = , XF86AudioLowerVolume, exec, pamixer -d 10
  bind = , XF86AudioMute, exec, pamixer -t

  # Screenshot
  bind = , Print, exec, grimblast --notify copy output
  bind = $mainMod, Print, exec, grimblast --notify save output "$HOME/Screenshots/$(date +%Y-%m-%dT%H:%M:%S).png"

  #---------#
  # Monitor #
  #---------#
  monitor=,preferred,auto,1

  #---------------#
  # Input Devices #
  #---------------#
  input {
      kb_layout = us
      repeat_delay = 400
      repeat_rate = 15
      follow_mouse = 1
      sensitivity = -0.5 # -1.0 - 1.0, 0 means no modification.

      touchpad {
          natural_scroll = true
      }
  }

  #------------#
  # Appearance #
  #------------#
  general {
      gaps_in = 5
      gaps_out = 5
      border_size = 2
      col.active_border = rgb(${colors.blue})
      col.inactive_border = rgb(${colors.bg})
      cursor_inactive_timeout
      layout = dwindle
  }

  decoration {
      rounding = 10
      blur = yes
      blur_size = 3
      blur_passes = 1
      blur_new_optimizations = on

      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
  }

  animations {
      enabled = yes

      bezier = myBezier, 0.05, 0.9, 0.1, 1.05

      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
  }

  dwindle {
      pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = yes # you probably want this
  }

  master {
      new_is_master = true
  }

  gestures {
      workspace_swipe = off
  }

  # Example per-device config
  # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
  device:epic mouse V1 {
      sensitivity = -0.5
  }

  # Example windowrule v1
  # windowrule = float, ^(kitty)$
  # Example windowrule v2
  # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
  # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

  #--------------#
  # Applications #
  #--------------#
  # Launcher
  bind = $mainMod, s, exec, wofi --show=drun -I
  # Emoji
  bind = $mainMod, period, exec, wofi-emoji

  #-----------#
  # Autostart #
  #-----------#
  exec-once = mako
  exec-once = fcitx5 -D
  exec-once = systemctl start --user xremap.service
  exec-once = swaybg --image ~/.config/hypr/wallpapers/solar_system.jpg --mode fill

  exec-once = discord --start-minimized
  exec-once = slack -u
  exec-once = teams-for-linux --minimized
''
