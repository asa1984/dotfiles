{pkgs, ...}: {
  # User environment
  users.users.asahi = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "docker" "audio" "video"];
  };
  environment = {
    shells = [pkgs.zsh];
    systemPackages = with pkgs; [
      zsh
      git
      neovim
      docker-compose
    ];
  };
  programs.zsh.enable = true;

  # Network
  networking = {
    networkmanager.enable = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false; # nixpkgs issue#180175
  services.tailscale.enable = true;

  # Localization
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-mozc fcitx5-gtk];
  };

  # Nix
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

  # Virtualization
  virtualisation = {docker.enable = true;};

  system = {
    stateVersion = "22.11";
  };
}
