{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.services.darwin-auto-update;

  updateScript = pkgs.writeShellScript "nix-darwin-auto-update" ''
        export PATH="/run/current-system/sw/bin:${pkgs.nix}/bin:${pkgs.git}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        DOTFILES_DIR="${cfg.dotfilesDir}"
        FLAKE_DIR="${cfg.flakeDir}"

        notify() {
          local message="$1"
          local sound="''${2:-Frog}"
          osascript -e "display notification \"$message\" with title \"nix-darwin\" sound name \"$sound\"" || true
        }

        ask_apply() {
          osascript << 'APPLESCRIPT' 2>/dev/null
    display alert "nix-darwin アップデート" message "ビルドが完了しました。今すぐ適用しますか？" buttons {"後で", "適用"} default button "適用"
    APPLESCRIPT
        }

        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
        }

        # 1. リポジトリが clean か確認
        cd "$DOTFILES_DIR"
        if [ -n "$(git status --porcelain)" ]; then
          log "Repository is dirty, skipping auto-update"
          exit 0
        fi

        # 2. git pull
        log "Pulling latest changes..."
        OLD_HEAD=$(git rev-parse HEAD)

        if ! git pull --ff-only 2>&1; then
          log "ERROR: git pull failed"
          notify "git pull に失敗しました" "Basso"
          exit 1
        fi

        NEW_HEAD=$(git rev-parse HEAD)
        if [ "$OLD_HEAD" = "$NEW_HEAD" ]; then
          log "Already up to date"
          exit 0
        fi

        # 3. ビルド (dry-run)
        log "Building system configuration..."
        notify "変更を検出、ビルド中..." "Frog"

        if ! darwin-rebuild build --flake "$FLAKE_DIR" 2>&1; then
          log "ERROR: Build failed"
          notify "ビルドに失敗しました。ログを確認してください。" "Basso"
          exit 1
        fi

        log "Build complete, asking user for approval..."

        # 4. ユーザーに承認を求める
        if ask_apply | grep -q "適用"; then
          # 5. 適用
          log "Applying configuration..."
          if sudo darwin-rebuild switch --flake "$FLAKE_DIR" 2>&1; then
            log "Switch complete"
            notify "システムの更新が完了しました" "Glass"
          else
            log "ERROR: Switch failed"
            notify "適用に失敗しました。ログを確認してください。" "Basso"
            exit 1
          fi
        else
          log "User deferred update"
          notify "更新を延期しました。手動で darwin-rebuild switch を実行してください。" "Frog"
        fi
  '';
in
{
  options.services.darwin-auto-update = {
    enable = lib.mkEnableOption "nix-darwin automatic update service";

    dotfilesDir = lib.mkOption {
      type = lib.types.str;
      description = "Path to the dotfiles git repository root";
    };

    flakeDir = lib.mkOption {
      type = lib.types.str;
      description = "Path to the nix-darwin flake";
    };

    schedule = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.int);
      default = [
        {
          Hour = 9;
          Minute = 0;
        }
      ];
      description = "launchd StartCalendarInterval schedule for the update check";
    };
  };

  config = lib.mkIf cfg.enable {
    security.sudo.extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
    '';

    launchd.user.agents.nix-darwin-auto-update = {
      serviceConfig = {
        Label = "com.asa1984.nix-darwin-auto-update";
        ProgramArguments = [ "${updateScript}" ];
        StartCalendarInterval = cfg.schedule;
        StandardOutPath = "/tmp/nix-darwin-auto-update.log";
        StandardErrorPath = "/tmp/nix-darwin-auto-update.err";
        EnvironmentVariables = {
          HOME = "/Users/${username}";
        };
      };
    };
  };
}
