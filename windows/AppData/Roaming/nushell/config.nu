# nushell configuration (managed by chezmoi)
# zsh 設定 (configs/home-manager/zsh) から必要なものだけ移植している。
# eza/bat 系 alias は nushell の構造化 ls/open を活かすため移植しない。

$env.config.show_banner = false

# --- Git ---
alias g = git
alias ga = git add .
alias gc = git commit
alias gco = git checkout
alias gsw = git switch
alias gswc = git switch -c

# nushell では外部コマンドの失敗が後続を止めるので `;` が zsh の `&&` 相当になる
def gac [] { git add .; git commit }
def gacp [] { git add .; git commit; git push }

# --- cd helpers ---
# git リポジトリのルートへ
def --env cdg [] { cd (git rev-parse --show-toplevel | str trim) }

# 一時ディレクトリへ
def --env cdtemp [] { cd (mktemp -d) }

# mkdir して cd
def --env mkcd [dir: string] { mkdir $dir; cd $dir }

# --- ghq ---
# ghq 管理リポジトリを fzf で選んで cd (zsh の ^G バインドと同じ)
def --env ghq-cd [] {
    let repo = ghq list | fzf | str trim
    if ($repo | is-empty) { return }
    cd ([(ghq root | str trim), $repo] | path join)
}

$env.config.keybindings ++= [
    {
        name: ghq_cd
        modifier: control
        keycode: char_g
        mode: [emacs, vi_normal, vi_insert]
        event: { send: executehostcommand, cmd: "ghq-cd" }
    }
]
