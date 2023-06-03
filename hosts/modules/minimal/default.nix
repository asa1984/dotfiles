{
  pkgs,
  nixpkgs,
  ...
}: {
  imports = [
    ./nix.nix
    ./services.nix
    ./virtualisation.nix
  ];

  # user environment
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
    ];
  };
  programs.zsh.enable = true;

  # network
  networking = {
    networkmanager.enable = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false; # nixpkgs issue#180175

  # localize
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-mozc fcitx5-gtk];
  };

  # allow proprietary software
  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = "22.11";
  };
}
