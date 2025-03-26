{ pkgs, ... }:
{
  fonts.packages = with pkgs; [ hackgen-nf-font ];
  security.pam.services.sudo_local.touchIdAuth = true;
}
