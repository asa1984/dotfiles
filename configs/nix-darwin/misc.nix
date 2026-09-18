{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    hackgen-nf-font
    # HackGen NF に無い新しめの Nerd Font グリフ (cod-claude など) のフォールバック
    nerd-fonts.symbols-only
    # herdr のサイドバーに出すエージェントのロゴと状態の記号 (herdr-glance が使う)
    herdr-agent-icons
  ];
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
