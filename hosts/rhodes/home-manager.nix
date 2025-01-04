{ lib, pkgs, ... }:
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
    parsec-bin
    slack
    spotify
    vscode
    zoom-us
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [ "eDP-1, 1920x1080@60, 0x0, 1" ];
    workspace = [
      "1,monitor:eDP-1"
      "2,monitor:eDP-1"
      "3,monitor:eDP-1"
      "4,monitor:eDP-1"
      "5,monitor:eDP-1"
      "6,monitor:eDP-1"
      "7,monitor:eDP-1"
      "8,monitor:eDP-1"
      "9,monitor:eDP-1"
      "10,monitor:eDP-1"
    ];
    input = {
      kb_layout = "jp";
      sensitivity = lib.mkForce 0.2;
    };
  };
}
