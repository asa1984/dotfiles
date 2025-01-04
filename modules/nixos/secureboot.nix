{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.secureboot;
in
{
  options.secureboot = {
    enable = mkEnableOption "Secure Boot";
    pkiBundle = mkOption {
      type = types.str;
      default = "/etc/secureboot";
      description = "Path to the PKI bundle";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = [ pkgs.sbctl ];
    }

    {
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = cfg.pkiBundle;
      };
    }
  ]);
}
