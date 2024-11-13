{
  inputs,
  pkgs,
  lib,
  config,
  username,
  ...
}:
{
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/core
      ../../modules/desktop
      ../../modules/programs/flatpak.nix
      ../../modules/programs/hyprland.nix
      ../../modules/programs/keybase.nix
      ../../modules/programs/media.nix
      ../../modules/programs/nix-ld.nix
      ../../modules/programs/secureboot.nix
      ../../modules/programs/shell.nix
      ../../modules/programs/steam.nix
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd
      common-gpu-amd
      common-pc-ssd
    ]);

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

  # Don't touch this
  system.stateVersion = "22.11";

  sops.secrets.login-password.neededForUsers = true;

  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.login-password.path;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --cmd ${lib.getExe config.programs.hyprland.package}";
        user = username;
      };
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };
}
