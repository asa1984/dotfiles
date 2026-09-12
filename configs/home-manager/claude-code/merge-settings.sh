#!/usr/bin/env bash
# Nix が宣言するベース設定を、Claude Code 自身が書き換える settings.json へマージする。
#   $1: ベース設定 (nix store の JSON)
#   $2: マージ先 (~/.claude/settings.json)
# `.[0] * .[1]` は再帰マージで右辺 (= Nix) が勝つ。宣言していないキー
# (autoMode.environment など Claude Code が学習して書き込むもの) はそのまま残る。

base="$1"
target="$2"

mkdir -p "$(dirname "$target")"

# 過去に home.file で store シンボリックリンクを張っていた場合、Claude Code は
# 実体パスの隣に一時ファイルを作れず EACCES で設定を保存できない。実体化する。
if [ -L "$target" ]; then
  rm -f "$target"
fi

if [ ! -s "$target" ]; then
  printf '{}\n' > "$target"
fi

if ! jq -e 'type == "object"' "$target" > /dev/null 2>&1; then
  echo "claude-code: $target が JSON オブジェクトではないため退避します" >&2
  mv "$target" "$target.bak.$(date +%s)"
  printf '{}\n' > "$target"
fi

tmp="$(mktemp "$target.hm.XXXXXX")"
jq -s '.[0] * .[1]' "$target" "$base" > "$tmp"
mv "$tmp" "$target"
