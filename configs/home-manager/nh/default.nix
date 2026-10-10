{
  config,
  lib,
  ...
}:
{
  programs.nh.enable = true;

  # 古い home-manager 世代と nix-direnv の GC root を掃除して nix store gc する。
  # direnv の root を消されたプロジェクトは、次に入ったとき nix-direnv が再評価する。
  # programs.nh.clean は darwin だと extraArgs を 1 引数で渡してしまい、PATH に nix も無いので自前で定義する。
  launchd.agents.nh-clean = {
    enable = true;
    config = {
      ProgramArguments = [
        (lib.getExe config.programs.nh.package)
        "clean"
        "user"
        "--keep-since"
        "14d"
      ];
      EnvironmentVariables.PATH = "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin";
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 0;
          Minute = 0;
        }
      ];
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/nh-clean.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/nh-clean.log";
    };
  };
}
