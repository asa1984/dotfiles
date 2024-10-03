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

    ../../modules/core
    ../../modules/programs/shell.nix
  ];

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

  # Don't touch this
  system.stateVersion = "23.05";

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
