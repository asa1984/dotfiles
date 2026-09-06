{ hostname, inputs, pkgs, ... }:
{
  imports = [
    inputs.comin.darwinModules.comin
  ];

  services.comin = {
    enable = true;
    # flake.nix の場所: https://github.com/asa1984/dotfiles の hosts/<hostname>/
    # ?dir= を付けても取得されるのはリポジトリ全体のため、
    # flake 内の ../../lib, ../../modules 等の親参照は解決できる。
    repositorySubdir = "hosts/${hostname}";
    remotes = [
      {
        name = "origin";
        url = "https://github.com/asa1984/dotfiles.git";
        branches.main.name = "main";
        poller.period = 300;
      }
    ];

    # デプロイ試行のたびに呼ばれるフック。switch 失敗の検知用。
    # COMIN_STATUS は done / failed のいずれか。
    # 注意: eval 失敗・build 失敗ではデプロイ自体が試行されないため
    # このフックは呼ばれない。そちらは `comin status --json` と
    # /var/log/comin.log で確認する。
    postDeploymentCommand = pkgs.writeShellScript "comin-post-deployment" ''
      set -u
      log_file="/var/lib/comin/deployments.log"
      timestamp=$(/bin/date -u "+%Y-%m-%dT%H:%M:%SZ")
      sha_short=$(printf "%.12s" "$COMIN_GIT_SHA")
      printf '%s host=%s ref=%s sha=%s status=%s\n' \
        "$timestamp" "$COMIN_HOSTNAME" "$COMIN_GIT_REF" "$sha_short" "$COMIN_STATUS" >> "$log_file"
      /usr/bin/tail -n 1000 "$log_file" > "$log_file.tmp" && /bin/mv "$log_file.tmp" "$log_file"

      if [ "$COMIN_STATUS" = "done" ]; then
        exit 0
      fi

      /usr/bin/logger -t comin "deployment failed: host=$COMIN_HOSTNAME ref=$COMIN_GIT_REF sha=$COMIN_GIT_SHA error=$COMIN_ERROR_MSG"
      console_user=$(/usr/bin/stat -f %Su /dev/console 2>/dev/null || true)
      if [ -n "$console_user" ] && [ "$console_user" != "root" ]; then
        safe_err=$(printf '%s' "$COMIN_ERROR_MSG" | /usr/bin/tr -d '"' | /usr/bin/cut -c1-200)
        /usr/bin/sudo -u "$console_user" /usr/bin/osascript \
          -e "display notification \"$safe_err\" with title \"comin: $COMIN_HOSTNAME デプロイ失敗\"" || true
      fi
    '';
  };
}
