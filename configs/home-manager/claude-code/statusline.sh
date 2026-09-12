# Claude Code の statusLine コマンド。
#
#   {dir} | {branch} ({diff})
#   {model} ({effort}) | {bar} {ctx%} | 5h: {%} | Weekly: {%} | Fable Weekly: {%}
#
# stdin の JSON (Claude Code 2.1.261) のうち使っているフィールド:
#   .workspace.current_dir                  string
#   .model.display_name                     string
#   .effort.level                           "low" | "medium" | "high" | "xhigh" | "max"
#                                           (effort 非対応モデルでは無い)
#   .context_window.used_percentage         number (0-100) | null (最初の応答までは null)
#   .rate_limits.five_hour.used_percentage  number (0-100) (サブスクリプション利用時のみ)
#   .rate_limits.seven_day.used_percentage  number (0-100) (同上)
#
# モデル別の週次上限 (Fable Weekly) は stdin には来ない。Claude Code が
# ~/.claude.json の cachedUsageUtilization に保存する使用量 API の応答から読む。

input=$(cat)

esc=$'\033'
reset="${esc}[0m"
c_dim="${esc}[2m"
c_dir="${esc}[2;34m"
c_branch="${esc}[2;32m"
c_add="${esc}[2;32m"
c_del="${esc}[2;31m"
c_model="${esc}[2;35m"
c_pct="${esc}[2;36m"
c_warn="${esc}[33m"
c_alert="${esc}[1;31m"

# ロケールに依存しないよう UTF-8 のバイト列で書く
icon_dir=$'\xef\x90\x93'    # U+F413 nf-oct-file_directory
icon_branch=$'\xef\x90\x98' # U+F418 nf-oct-git_branch

sep=" ${c_dim}|${reset} "

# 使用率 (整数 %) に応じた色。90% 超で warn、95% 超で alert。
pct_color() {
  if (($1 > 95)); then
    printf '%s' "$c_alert"
  elif (($1 > 90)); then
    printf '%s' "$c_warn"
  else
    printf '%s' "$c_pct"
  fi
}

# 使用率 (整数 %) を 10 マスのバーにする
bar() {
  local width=10 filled i out=""
  filled=$((($1 * width + 50) / 100))
  if ((filled > width)); then
    filled=$width
  fi
  for ((i = 0; i < width; i++)); do
    if ((i < filled)); then out+="█"; else out+="░"; fi
  done
  printf '%s' "$out"
}

# "5h: 12%" のような 1 セグメント
limit() {
  printf '%s%s:%s %s%s%%%s' "$c_dim" "$1" "$reset" "$(pct_color "$2")" "$2" "$reset"
}

# 空のフィールドが潰れないよう、区切りには空白ではない US (0x1f) を使う
us=$'\x1f'
IFS=$us read -r cwd model effort ctx five week < <(
  jq -r --arg us "$us" 'def pct: if . == null then null else round end;
    [ .workspace.current_dir // .cwd,
      .model.display_name,
      .effort.level,
      (.context_window.used_percentage | pct),
      (.rate_limits.five_hour.used_percentage | pct),
      (.rate_limits.seven_day.used_percentage | pct)
    ] | map(. // "" | tostring) | join($us)' <<<"$input"
)

# Claude Code 自身と同じく、取得から 1 時間を過ぎたキャッシュは使わない。
# /usage などで使用量を取得したときにしか更新されないので、無いことも多い。
fable=$(jq -r 'first(
    .cachedUsageUtilization
    | select(. != null and (now * 1000 - .fetchedAtMs) < 3600000)
    | .utilization.limits[]?
    | select(.kind == "weekly_scoped" and .scope.model.display_name == "Fable")
    | .percent | round
  ) // empty' "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" 2>/dev/null)

dir_label=""
branch=""
diff=""
if { read -r top && read -r gitdir && read -r common; } < <(
  git -C "$cwd" rev-parse --path-format=absolute --show-toplevel --git-dir --git-common-dir 2>/dev/null
); then
  if url=$(git -C "$cwd" remote get-url origin 2>/dev/null); then
    # git@host:owner/repo.git でも https://host/owner/repo.git でも末尾の 2 要素を取る
    url=${url%.git}
    owner=${url%/*}
    dir_label="${owner##*[:/]}/${url##*/}"
  else
    # worktree でも本体のリポジトリ名になるよう、共通の .git の親から取る
    repo_root=${common%/*}
    dir_label=${repo_root##*/}
  fi
  if [[ $gitdir != "$common" ]]; then
    dir_label+=":${top##*/}"
  fi

  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [[ -z $branch ]]; then
    branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null) # detached HEAD
  fi

  # HEAD からの差分 (staged + unstaged)。untracked は含まない。
  stat=$(git -C "$cwd" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
  added=0
  deleted=0
  if [[ $stat =~ ([0-9]+)\ insertion ]]; then added=${BASH_REMATCH[1]}; fi
  if [[ $stat =~ ([0-9]+)\ deletion ]]; then deleted=${BASH_REMATCH[1]}; fi
  if ((added + deleted > 0)); then
    diff=" ${c_dim}(${reset}${c_add}+${added}${reset} ${c_del}-${deleted}${reset}${c_dim})${reset}"
  fi
elif [[ $cwd == "$HOME" || $cwd == "$HOME"/* ]]; then
  dir_label="~${cwd#"$HOME"}"
else
  dir_label=$cwd
fi

line1="${c_dir}${icon_dir} ${dir_label}${reset}"
if [[ -n $branch ]]; then
  line1+="${sep}${c_branch}${icon_branch} ${branch}${reset}${diff}"
fi

line2="${c_model}${model}"
if [[ -n $effort ]]; then
  line2+=" (${effort})"
fi
line2+=$reset
if [[ -n $ctx ]]; then
  line2+="${sep}$(pct_color "$ctx")$(bar "$ctx") ${ctx}%${reset}"
fi
if [[ -n $five ]]; then line2+="${sep}$(limit 5h "$five")"; fi
if [[ -n $week ]]; then line2+="${sep}$(limit Weekly "$week")"; fi
if [[ -n $fable ]]; then line2+="${sep}$(limit "Fable Weekly" "$fable")"; fi

printf '%s\n%s' "$line1" "$line2"
