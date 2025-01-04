{
  pkgs,
  hostname,
  username,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../../configs/nixos/core/docker.nix
    ../../configs/nixos/core/network.nix
    ../../configs/nixos/core/nix.nix
    ../../configs/nixos/core/shell.nix

    ../../configs/nixos/apps/keybase.nix
    ../../configs/nixos/apps/sops.nix
    ../../configs/nixos/apps/tailscale.nix
  ];

  # Don't touch this
  system.stateVersion = "23.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;

  users.users."${username}" = {
    isNormalUser = true;
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

  programs.nix-ld.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
  };
}
