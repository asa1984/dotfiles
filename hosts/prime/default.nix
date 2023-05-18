{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../modules/minimal
    ../modules/fonts.nix
    ../modules/games.nix
    ../modules/security.nix
    ../modules/services.nix
    ../modules/sound.nix
    #    ../modules/xremap.nix

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

  networking.hostName = "nixos-prime"; # define your hostname
}
