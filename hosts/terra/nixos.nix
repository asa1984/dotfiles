{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/core
      ../../modules/desktop
      ../../modules/programs/flatpak.nix
      ../../modules/programs/hyprland.nix
      ../../modules/programs/media.nix
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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland
        '';
        user = username;
      };
    };
  };
}
