{ config, lib, ... }:
let
  cfg = config.homebrew;
in
{
  # brew bundle は古いバージョンのダウンロードを ~/Library/Caches/Homebrew に溜め続けるので、activation のたびに捨てる
  system.activationScripts.homebrew.text = lib.mkIf cfg.enable (
    lib.mkAfter ''
      if [ -f "${cfg.prefix}/bin/brew" ]; then
        sudo --user=${lib.escapeShellArg cfg.user} --set-home "${cfg.prefix}/bin/brew" cleanup --prune=all \
          || echo "warning: brew cleanup に失敗しました" >&2
      fi
    ''
  );
}
