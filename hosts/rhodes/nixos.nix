{
  inputs,
  pkgs,
  hostname,
  username,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix

      ../../modules/flatpak.nix
      ../../modules/fcitx5.nix
      ../../modules/fonts.nix
      ../../modules/i18n.nix
      ../../modules/networking.nix
      ../../modules/sound.nix
      ../../modules/system-tools.nix
      ../../modules/virtualisation.nix
      ../../modules/xremap.nix
      ../../modules/xserver.nix
    ]
    ++ (with inputs.nixos-hardware.nixosModules; [
      common-cpu-amd
      common-gpu-amd
      common-pc-ssd
      common-pc-laptop
    ]);

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

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

  # Use session generated by home-manager
  services.xserver = {
    displayManager = {
      lightdm = {
        enable = true;
        background = pkgs.fetchurl {
          url = "https://i.redd.it/49mj5c88ndla1.jpg";
          sha256 = "sha256-idMl5YkMMrXfBW36eG0buuJZ1IjmZLG/5TwfVROmC2s=";
        };
      };
      defaultSession = "home-manager";
    };
    desktopManager = {
      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # Don't touch this
  system.stateVersion = "22.11";
}
