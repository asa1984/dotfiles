{
  imports = [
    # home profile
    ./home.nix

    ./programs/cli
    ./programs/gui
    ./programs/desktop/hyprland
    ../modules/xmonad
    ../modules/rofi
    ../modules/dunst
  ];
}
