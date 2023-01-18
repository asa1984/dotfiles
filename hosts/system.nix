{ pkgs, nixpkgs, ... }:
{
  #TODO: add nix settings
  #TODO: add system packages
  #TODO: add service settings

  networking = {
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    shells = with pkgs; [ zsh ];
  };

  services = { dbus.enable = true; };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = "22.11";
  };
}
