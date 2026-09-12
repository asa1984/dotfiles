{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        # lazygit 0.65 で git.pagers から改名された。旧形式のままだと起動時に
        # 設定ファイルを自動移行しようとし、読み取り専用の store ファイルに
        # 書き込めずに落ちる。
        diffRenderers = [
          {
            type = "extDiff";
            command = "${pkgs.difftastic}/bin/difft --color=always";
          }
        ];
      };
    };
  };
}
