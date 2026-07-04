{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  herdr = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
in
{
  home.packages = [ herdr ];

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
}
