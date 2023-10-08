{
  pkgs,
  hostname,
  username,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/i18n.nix
    ../../modules/networking.nix
    ../../modules/nix.nix
    ../../modules/virtualisation.nix
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

  environment.systemPackages = with pkgs; [
    bottom
    direnv
    zellij
  ];

  programs = {
    git = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    zsh = {
      enable = true;
    };
  };

  # Don't touch this
  system.stateVersion = "23.05";

  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
