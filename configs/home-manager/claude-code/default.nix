{
  config,
  lib,
  pkgs,
  ...
}:
let
  claudeDir = "${config.home.homeDirectory}/.claude";

  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [
      coreutils
      git
      jq
    ];
    bashOptions = [
      "nounset"
      "pipefail"
    ];
    text = builtins.readFile ./statusline.sh;
  };

  # Nix が所有する settings.json のキー。
  # ここに書いたキーは `just switch-darwin` のたびに Nix の値へ戻る。
  # 逆に書かなかったキー (autoMode.environment など Claude Code が自分で
  # 学習・更新するもの) は活性化しても保持される。
  settings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    permissions.defaultMode = "auto";
    skipDangerousModePermissionPrompt = true;

    tui = "fullscreen";
    editorMode = "vim";
    agentPushNotifEnabled = true;
    voiceEnabled = true;

    statusLine = {
      type = "command";
      command = lib.getExe statusline;
    };

    hooks = {
      # スクリプト本体 (hooks/herdr-agent-state.sh) は herdr が所有する
      # (`herdr integration install claude` が設置し、更新時に上書きする)。
      SessionStart = [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "bash '${claudeDir}/hooks/herdr-agent-state.sh' session";
              timeout = 10;
            }
          ];
        }
      ];
    };

    # LSP は下の programs.claude-code.lspServers で store パス固定にしたため、
    # PATH 上のバイナリを前提とする公式 LSP プラグインは無効化する。
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = false;
      "gopls-lsp@claude-plugins-official" = false;
      "lua-lsp@claude-plugins-official" = false;
      "rust-analyzer-lsp@claude-plugins-official" = false;
    };
  };

  settingsFile = (pkgs.formats.json { }).generate "claude-code-settings.json" settings;

  mergeSettings = pkgs.writeShellApplication {
    name = "claude-code-merge-settings";
    runtimeInputs = with pkgs; [
      coreutils
      jq
    ];
    text = builtins.readFile ./merge-settings.sh;
  };
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;

    # settings は敢えて空にしておく。
    # home-manager モジュールは settings を home.file 経由で nix store への
    # シンボリックリンクとして張るが、Claude Code は settings.json を
    # 実行時に書き換える (/config, /plugin, ユーザースコープの権限追加,
    # autoMode の環境学習)。書き込みは realpath の隣に `.tmp.<pid>.<rand>`
    # を作ってから rename する実装なので、リンク先が読み取り専用の store だと
    # EACCES で失敗し設定を保存できなくなる。
    # そのため実体ファイルを持たせ、下の activation でマージする。
    settings = { };

    skills = {
      japanese-tech-writing = ./skills/japanese-tech-writing;
    };

    # LSP サーバー。settings.json ではなく `--plugin-dir` 経由の .lsp.json として
    # 渡るため、Claude Code に書き換えられる余地がなく store パスで固定できる。
    # コマンドが絶対パスなので PATH 汚染や go install 等の手動セットアップも不要。
    # サーバー本体は asa1984.nvim の editorTools と同じものを選んでいる。
    lspServers = {
      clangd = {
        command = "${pkgs.clang-tools}/bin/clangd";
        args = [ "--background-index" ];
        extensionToLanguage = {
          ".c" = "c";
          ".h" = "c";
          ".cc" = "cpp";
          ".cpp" = "cpp";
          ".cxx" = "cpp";
          ".hpp" = "cpp";
          ".hxx" = "cpp";
        };
      };

      gopls = {
        command = lib.getExe pkgs.gopls;
        extensionToLanguage.".go" = "go";
      };

      lua = {
        command = lib.getExe pkgs.lua-language-server;
        extensionToLanguage.".lua" = "lua";
      };

      rust-analyzer = {
        command = lib.getExe pkgs.rust-analyzer;
        extensionToLanguage.".rs" = "rust";
      };

      nil = {
        command = lib.getExe pkgs.nil;
        extensionToLanguage.".nix" = "nix";
      };

      # TypeScript は tsc v7 (typescript-go / tsgo) の LSP モードを使う。
      #
      # 注意: tsc 7.0.2 は publishDiagnostics を push しない (pull 専用の
      # textDocument/diagnostic のみ実装)。一方 Claude Code は push しか
      # 実装していないため、編集後の型エラー自動注入は効かない。
      # 補完/定義ジャンプ/参照/リネーム/hover/シンボルは問題なく動く。
      # diagnostics も自動で欲しくなったら vtsls (pkgs.vtsls, args = [ "--stdio" ]) に戻す。
      tsgo = {
        command = "${pkgs.typescript}/bin/tsc";
        args = [
          "--lsp"
          "--stdio"
        ];
        extensionToLanguage = {
          ".ts" = "typescript";
          ".mts" = "typescript";
          ".cts" = "typescript";
          ".tsx" = "typescriptreact";
          ".js" = "javascript";
          ".mjs" = "javascript";
          ".cjs" = "javascript";
          ".jsx" = "javascriptreact";
        };
      };

      pyright = {
        command = "${pkgs.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
        extensionToLanguage = {
          ".py" = "python";
          ".pyi" = "python";
        };
      };

      # 診断には shellcheck が要る (cli-utilities 側では入れていないのでここで渡す)
      bash = {
        command = lib.getExe pkgs.bash-language-server;
        args = [ "start" ];
        env.PATH = lib.makeBinPath [ pkgs.shellcheck ];
        extensionToLanguage = {
          ".sh" = "shellscript";
          ".bash" = "shellscript";
        };
      };

      terraform-ls = {
        command = lib.getExe pkgs.terraform-ls;
        args = [ "serve" ];
        extensionToLanguage = {
          ".tf" = "terraform";
          ".tfvars" = "terraform-vars";
        };
      };
    };
  };

  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe mergeSettings} ${settingsFile} ${lib.escapeShellArg "${claudeDir}/settings.json"}
  '';
}
