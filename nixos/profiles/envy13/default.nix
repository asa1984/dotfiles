{ config, pkgs, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../modules/sound
      ../../modules/fonts
      ../../modules/services
      ../../modules/virtualisation
    ];

  networking.hostName = "nixos-laptop-hp"; # Define your hostname.

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "jp";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "jp106";

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
