{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../modules/minimal
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

  networking.hostName = "asahi@prime"; # define your hostname
}
