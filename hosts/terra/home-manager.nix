{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager

    ../../configs/home-manager/cli-utilities
    ../../configs/home-manager/direnv
    ../../configs/home-manager/fcitx5
    ../../configs/home-manager/gh
    ../../configs/home-manager/git
    ../../configs/home-manager/gtk
    ../../configs/home-manager/gui-utilities
    ../../configs/home-manager/hyprland
    ../../configs/home-manager/lazygit
    ../../configs/home-manager/neovim
    ../../configs/home-manager/starship
    ../../configs/home-manager/vivaldi
    ../../configs/home-manager/wezterm
    ../../configs/home-manager/xdg
    ../../configs/home-manager/zsh
  ];

  development.enable = true;

  home.packages = with pkgs; [
    discord
    discord-ptb
    jdk
    parsec-bin
    prismlauncher # alternative minecraft launcher
    slack
    spotify
    vscode
    zoom-us
  ];

  programs = {
    firefox.enable = true;
    google-chrome.enable = true;
    ncspot.enable = true;
    obs-studio.enable = true;
  };

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
}
