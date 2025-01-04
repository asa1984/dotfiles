{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.keybase-service;
in
{
  options = {
    services.keybase-service = {
      enable = mkEnableOption "Keybase";
      package = mkPackageOption pkgs "keybase" { };
    };
  };

  config = mkIf cfg.enable (mkMerge ([
    {
      home.packages = [ cfg.package ];
    }

    (mkIf pkgs.stdenv.isLinux {
      systemd.user.services.keybase = {
        Unit.Description = "Keybase service";
        Service = {
          ExecStart = "${pkgs.keybase}/bin/keybase service --auto-forked";
          Restart = "on-failure";
          PrivateTmp = true;
        };
        Install.WantedBy = [ "default.target" ];
      };
    })

    (mkIf pkgs.stdenv.isDarwin {
      launchd.agents.keybase = {
        enable = true;
        config = {
          ProgramArguments = [
            "${pkgs.keybase}/bin/keybase"
            "service"
            "--auto-forked"
          ];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };
    })
  ]));
}
