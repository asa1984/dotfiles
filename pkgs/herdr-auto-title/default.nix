{ buildGoModule, fetchFromGitHub, ... }:
# Herdr のタブ名を自動で付けるプラグイン。
# `herdr plugin install` はインストール時に go build するが、`herdr plugin link` は
# [[build]] を実行しない。そこで Nix でビルドしたバイナリとマニフェストを
# share/herdr-auto-title に並べ、そのディレクトリをリンクして使う。
buildGoModule rec {
  pname = "herdr-auto-title";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "kryptamine";
    repo = "herdr-auto-title";
    tag = "v${version}";
    hash = "sha256-IophxKOw4kbYApUu61paYrX1wYcocvaKqb/zEbNeycw=";
  };
  vendorHash = "sha256-QxFp1b7pf7bn3Hh0hyaj8ke5Z61N+WwjhHt3pFiapTs=";

  # マニフェストの [[startup]] はプラグインルートの ./herdr-auto-title を起動する
  postInstall = ''
    install -Dm644 herdr-plugin.toml $out/share/herdr-auto-title/herdr-plugin.toml
    ln -s $out/bin/herdr-auto-title $out/share/herdr-auto-title/herdr-auto-title
  '';
}
