{ config, pkgs, user, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../modules/hyprland
    ];

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];

  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Hostname
  networking.hostName = "nixos-desktop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Time zone.
  time.timeZone = "Asia/Tokyo";

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Select internationalisation properties.
  i18n.defaultLocale = defaultLanguage;

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  environment.shells = with pkgs; [ zsh ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
