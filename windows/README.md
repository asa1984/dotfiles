# Windows configuration (chezmoi)

Windows ネイティブ環境の設定。Nix ではなく [chezmoi](https://www.chezmoi.io/) で管理する。
リポジトリルートの `.chezmoiroot` によりこのディレクトリが chezmoi のソースルートになる。

## セットアップ

```powershell
winget install twpayne.chezmoi
chezmoi init --apply https://github.com/asa1984/dotfiles
```

既に ghq でクローン済みの場合は `~/.config/chezmoi/chezmoi.toml` に以下を書く:

```toml
sourceDir = "C:/Users/<user>/ghq/github.com/asa1984/dotfiles"
```

## スタック

- パッケージ: winget (GUI アプリ) + scoop (CLI ツール)
- OS 設定: WinGet Configuration (DSC v3)
- 言語ツールチェーン: mise
- シェル: nushell / ターミナル: WezTerm / フォント: HackGen Console NF
