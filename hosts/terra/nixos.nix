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

      ../../configs/nixos/core/docker.nix
      ../../configs/nixos/core/network.nix
      ../../configs/nixos/core/nix.nix
      ../../configs/nixos/core/shell.nix

      ../../configs/nixos/apps/flatpak.nix
      ../../configs/nixos/apps/keybase.nix
      ../../configs/nixos/apps/keyring.nix
      ../../configs/nixos/apps/secureboot.nix
      ../../configs/nixos/apps/sops.nix
      ../../configs/nixos/apps/steam.nix
      ../../configs/nixos/apps/sunshine.nix
      ../../configs/nixos/apps/tailscale.nix
      ../../configs/nixos/apps/xremap.nix

      ../../configs/nixos/desktop/fcitx5.nix
      ../../configs/nixos/desktop/fonts.nix
      ../../configs/nixos/desktop/hyprland.nix
      ../../configs/nixos/desktop/sound.nix
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd
      common-gpu-amd
      common-pc-ssd
    ]);

  # Don't touch this
  system.stateVersion = "22.11";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

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
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    droidcam.enable = true;
    nix-ld.enable = true;
    noisetorch.enable = true;
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
}
