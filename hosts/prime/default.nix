{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../modules/minimal
    ../modules/desktop.nix
    ../modules/fonts.nix
    ../modules/sound.nix
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

  networking.hostName = "nixos@prime"; # define your hostname
}
