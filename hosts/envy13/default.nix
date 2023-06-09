{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc-laptop

    ../modules/minimal
    ../modules/fonts.nix
    ../modules/laptop.nix
    ../modules/security.nix
    ../modules/services.nix
    ../modules/sound.nix
    # ../modules/xremap.nix

    # Desktop environment
    ../modules/desktop/hyprland.nix
    ../modules/desktop/xmonad.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "nixos-envy13"; # define your hostname
}
