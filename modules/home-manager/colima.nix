{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.colima;
in
{
  options.services.colima = {
    enable = mkEnableOption "Colima";
    package = mkPackageOption pkgs "colima" { };

    docker = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Docker";
      };
      package = mkPackageOption pkgs "docker" { };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ cfg.package ];
    }

    (mkIf cfg.docker.enable {
      home.packages = [ cfg.docker.package ];
    })

    (mkIf pkgs.stdenv.isDarwin {
      launchd.agents.colima = {
        enable = true;
        config = {
          ProgramArguments = [
            "${cfg.package}/bin/colima"
            "start"
            "--foreground"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          EnvironmentVariables = {
            PATH =
              if cfg.docker.enable then
                "${cfg.package}/bin:${cfg.docker.package}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
              else
                "${cfg.package}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
        };
      };
    })
  ]);
}
