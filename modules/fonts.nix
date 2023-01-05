{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hackgen-nf-font
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];
}
