{ pkgs, ... }:
{
  imports = [
    ../../home-manager/cli
    ../../home-manager/gui
    ../../home-manager/desktop/hyprland
    # ../../home-manager/desktop/xmonad
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 2560x1440@165, 1920x0, 1"
      "DP-2, 1920x1080@144, 0x0, 1"
    ];
    workspace = [
      "1,monitor:DP-1"
      "2,monitor:DP-1"
      "3,monitor:DP-1"
      "4,monitor:DP-1"
      "5,monitor:DP-1"
      "6,monitor:DP-1"
      "7,monitor:DP-1"
      "8,monitor:DP-1"
      "9,monitor:DP-1"
      "10,monitor:DP-1"

      "11,monitor:DP-2"
      "12,monitor:DP-2"
      "13,monitor:DP-2"
      "14,monitor:DP-2"
      "15,monitor:DP-2"
      "16,monitor:DP-2"
      "17,monitor:DP-2"
      "18,monitor:DP-2"
      "19,monitor:DP-2"
      "20,monitor:DP-2"
    ];
    input.kb_layout = "us";
  };

  home.packages = with pkgs; [
    prismlauncher # alternative minecraft launcher
    jdk20
  ];
}
