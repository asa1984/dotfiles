{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    hackgen-nf-font
    # HackGen NF に無い新しめの Nerd Font グリフ (cod-claude など) のフォールバック
    nerd-fonts.symbols-only
  ];
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
