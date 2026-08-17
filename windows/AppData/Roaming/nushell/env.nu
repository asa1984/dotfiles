# nushell env (chezmoi 管理)
# env.nu は config.nu のパースより先に実行されるため、
# config.nu が source する mise.nu をここで生成する

let mise_init = $nu.default-config-dir | path join "mise.nu"
if (which mise | is-not-empty) {
    ^mise activate nu | save -f $mise_init
} else if not ($mise_init | path exists) {
    # mise 未導入でも config.nu の source が失敗しないよう空ファイルを置く
    "" | save -f $mise_init
}
