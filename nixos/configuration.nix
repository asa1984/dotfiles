{ pkgs, nixpkgs, user, stateVersion, ... }: {
  # General and minimal system configurations

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };
  networking = {
    networkmanager.enable = true;
  };
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs;[ fcitx5-mozc ];
  };
  services = {
    openssh.enable = true;
  };

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" ];
  };

  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = with pkgs; [
      zsh
      git
      neovim
    ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow Nix to install proprietary packages
  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = stateVersion;
  };
}
