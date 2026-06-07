{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    # 手書きの tmux.conf をそのまま利用する。
    # home-manager が生成するデフォルト設定の後ろに追記されるため、
    # ここでの set が最終的に優先される。
    extraConfig = builtins.readFile ./tmux.conf;
  };

  # tmux.conf が参照する外部コマンド
  home.packages = with pkgs; [
    # copy-mode-vi の y / Enter で叩く pbcopy 連携
    reattach-to-user-namespace
  ];
}
