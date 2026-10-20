#! /usr/bin/env sh
# gh-q: fuzzy-find a GitHub repository owned by <owner> and `ghq get` it.
#
# Faster than the upstream kawarimidoll/gh-q implementation:
#   1. GraphQL page size 30 -> 100 (max), cutting API round trips to ~1/3.
#   2. `gh api user` is only called when <owner> is omitted (the original
#      always called it, wasting ~1 RTT even when <owner> was given),
#      and its result is cached (`gh --cache 1h`).
#   3. The repository list is cached on disk
#      (${XDG_CACHE_HOME:-~/.cache}/gh-q/<owner>.txt, TTL 1h by default),
#      so repeated selections need zero network requests.
#   4. A stale cache is served instantly while a refresh runs in the
#      background (stale-while-revalidate).
#   5. When fetching from the network, results are streamed into fzf page by
#      page, so filtering works before all repositories have been fetched.
#
usage() {
  cat <<'EOF'
gh-q: fuzzy-find a GitHub repository owned by <owner> and `ghq get` it.
Usage: gh-q [options] [<owner>] [-- <ghq-get-args>...]
  Options:
    -u, --refresh   Ignore the cache for reading (still updates it).
        --no-cache  Neither read nor write the cache.
    -h, --help      Show this help.
  Env:
    GH_Q_CACHE_TTL  Cache TTL in seconds (default 3600, 0 disables cache).
    GH_Q_NO_CACHE   Set to 1 to behave like --no-cache.
EOF
}
set -eu

OWNER=""
REFRESH=0
NO_CACHE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -u | --refresh)
      REFRESH=1
      shift
      ;;
    --no-cache)
      NO_CACHE=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "gh-q: unknown option: $1 (see --help)" >&2
      exit 2
      ;;
    *)
      if [ -z "$OWNER" ]; then
        OWNER="$1"
        shift
      fi
      break
      ;;
  esac
done

if [ -z "$OWNER" ]; then
  # Lazy + cached: only runs when <owner> was not given.
  OWNER="$(gh api user --jq '.login' --cache 1h)"
fi

CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}/gh-q"
TTL="${GH_Q_CACHE_TTL:-3600}"
case "$TTL" in
  '' | *[!0-9]*) TTL=3600 ;;
esac
if [ "${GH_Q_NO_CACHE:-0}" = "1" ]; then
  NO_CACHE=1
fi
if [ "$TTL" = "0" ]; then
  NO_CACHE=1
fi

SAFE_OWNER="$(printf '%s' "$OWNER" | tr -c 'A-Za-z0-9._-' '_')"
CACHE_FILE="$CACHE_BASE/$SAFE_OWNER.txt"

# shellcheck disable=SC2016 # GraphQL variables ($owner, $endCursor) are expanded by gh, not the shell.
QUERY='
query ($owner: String!, $endCursor: String) {
  repositoryOwner(login: $owner) {
    repositories(
      first: 100
      after: $endCursor
    ){
      pageInfo {
        hasNextPage
        endCursor
      }
      nodes {
        nameWithOwner
      }
    }
  }
}
'

fetch_repos() {
  gh api graphql --paginate \
    -F "owner=$OWNER" \
    -f query="$QUERY" \
    --jq '.data.repositoryOwner.repositories.nodes[].nameWithOwner'
}

cache_age() {
  # Echo age of $1 in seconds, or "unknown" when it cannot be determined.
  # GNU stat is pinned via runtimeInputs; BSD `stat -f %m` must not be used
  # because GNU `stat -f` prints file system info instead of failing cleanly.
  mtime="$(stat -c %Y "$1" 2>/dev/null || true)"
  case "$mtime" in
    '' | *[!0-9]*) printf 'unknown\n' && return 0 ;;
  esac
  printf '%s\n' "$(($(date +%s) - mtime))"
}

refresh_cache_bg() {
  # Stale-while-revalidate: update the cache without blocking the user.
  # Ignore SIGHUP so the refresh survives this script and its terminal exiting.
  tmp="$CACHE_FILE.tmp.$$"
  ( trap '' HUP; fetch_repos >"$tmp" 2>/dev/null && mv "$tmp" "$CACHE_FILE" ) >/dev/null 2>&1 &
}

stream_repos_bg() {
  # Stream the list into the FIFO $WORK/fifo while fetching. This runs in the
  # background so the script does not wait for the remaining pages once a
  # repository is selected; `tee -p` keeps filling the cache after fzf exits.
  if [ "$NO_CACHE" -eq 0 ]; then
    mkdir -p "$CACHE_BASE"
  fi
  tmp="$CACHE_FILE.tmp.$$"
  (
    trap '' HUP
    if [ "$NO_CACHE" -eq 1 ]; then
      fetch_repos 2>"$WORK/err" >"$WORK/fifo" || true
    elif fetch_repos 2>"$WORK/err" | tee -p "$tmp" >"$WORK/fifo"; then
      mv "$tmp" "$CACHE_FILE"
    else
      rm -f "$tmp"
    fi
    # Keep the error log for the foreground to report.
    [ -s "$WORK/err" ] || rm -rf "$WORK"
  ) &
}

select_repo() {
  fzf --prompt "gh-q($OWNER)> " || true
}

if [ "$NO_CACHE" -eq 0 ] && [ "$REFRESH" -eq 0 ] && [ -s "$CACHE_FILE" ]; then
  AGE="$(cache_age "$CACHE_FILE")"
  if [ "$AGE" = "unknown" ] || [ "$AGE" -ge "$TTL" ]; then
    # Stale (or unknown age) cache: select from it instantly, refresh behind the scenes.
    refresh_cache_bg
  fi
  REPO="$(select_repo <"$CACHE_FILE")"
else
  # Cold cache, --refresh or --no-cache: stream from the network.
  WORK="$(mktemp -d)"
  mkfifo "$WORK/fifo"
  stream_repos_bg
  REPO="$(select_repo <"$WORK/fifo")"
  if [ -z "$REPO" ] && [ -s "$WORK/err" ]; then
    cat "$WORK/err" >&2
    rm -rf "$WORK"
  fi
fi

if [ -z "$REPO" ]; then
  exit 1
fi

exec ghq get "$REPO" "$@"
