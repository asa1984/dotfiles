{
  imports = [
    # home profile
    ./home.nix

    ./programs/desktop/hyprland

    ../modules/cli
    ../modules/gui
    ../modules/desktop
  ];
}
