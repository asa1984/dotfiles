{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;

  # デスクトップ通知は Herdr Notify.app (pkgs/herdr-notify) に出させる。
  # macOS は通知の許可も、通知をクリックしたときに起動するアプリも bundle id から引くので、
  # store の .app (読み取り専用で署名し直せない) を ~/Applications に複製してから
  # アドホック署名し、LaunchServices に登録する (upstream の build.sh と同じ手順)。
  # 同じ store パスから複製済みなら何もしない。
  herdrNotifyApp = "${pkgs.herdr-notify}/Applications/Herdr Notify.app";
  installHerdrNotify = pkgs.writeShellApplication {
    name = "install-herdr-notify";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      src="${herdrNotifyApp}"
      app="$HOME/Applications/Herdr Notify.app"
      stamp="''${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/source"
      if [ -d "$app" ] && [ "$(cat "$stamp" 2>/dev/null)" = "$src" ]; then
        exit 0
      fi
      mkdir -p "$HOME/Applications" "$(dirname "$stamp")"
      rm -rf "$app"
      cp -R "$src" "$app"
      chmod -R u+w "$app"
      /usr/bin/codesign --force --sign - --identifier dev.herdr.notify "$app"
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
      printf '%s\n' "$src" > "$stamp"
    '';
  };

  # herdr の `[ui.toast] delivery = "system"` は PATH 上の terminal-notifier を呼ぶので、
  # その名前で Herdr Notify.app を呼び出す
  terminalNotifierShim = pkgs.writeShellScriptBin "terminal-notifier" ''
    exec "$HOME/Applications/Herdr Notify.app/Contents/MacOS/herdr-notify" "$@"
  '';
in
{
  home.packages = [
    herdr
    terminalNotifierShim
  ];

  home.file.".config/herdr/config.toml".source = ./config.toml;

  # herdr-splits プラグイン(herdr 側 / bash+lua でビルド不要)を flake input で pin し、
  # herdr 自身の `plugin link` で登録する。plugins.json は herdr が所有するため
  # 宣言的にファイルを置くのではなく、活性化時に冪等に(再)リンクする。
  # 既存の github インストール/リンクは除去してから store パスをリンクし直す。
  home.activation.herdrSplits = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${herdr}/bin/herdr plugin uninstall herdr-splits 2>/dev/null || true
    run ${herdr}/bin/herdr plugin unlink herdr-splits 2>/dev/null || true
    run ${herdr}/bin/herdr plugin link ${inputs.herdr-splits} 2>/dev/null || true
  '';

  # herdr-auto-title はタブ名を作業内容に追従させる Go 製プラグイン (pkgs/herdr-auto-title)。
  # `plugin link` は [[build]] を実行しないので、Nix でビルド済みのディレクトリをリンクする。
  # [[startup]] は link では走らず server の起動時にだけ走るため、毎回リンクし直しても
  # インスタンスは増えない。反映には `herdr server stop` での再起動が要る。
  # herdr 更新直後など、古い server が動いていると link は protocol_mismatch で拒否される。
  # switch 自体は止めずに、やり直し方を表示する。
  home.activation.herdrAutoTitle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${herdr}/bin/herdr plugin uninstall herdr.auto-title 2>/dev/null || true
    run ${herdr}/bin/herdr plugin unlink herdr.auto-title 2>/dev/null || true
    run ${herdr}/bin/herdr plugin link ${pkgs.herdr-auto-title}/share/herdr-auto-title \
      || echo "warning: herdr-auto-title の登録に失敗しました。'herdr server stop' で server を再起動してから switch し直してください" >&2
  '';

  home.activation.herdrNotify = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe installHerdrNotify}
  '';
}
