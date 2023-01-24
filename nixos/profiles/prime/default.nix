_: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/sound

    ../../modules/desktop/hyprland

    ../../modules/fonts
    ../../modules/services
    ../../modules/virtualisation
  ];

  # Hostname
  networking.hostName = "nixos-desktop"; # Define your hostname
}
