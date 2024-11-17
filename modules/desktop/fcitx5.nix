{ pkgs-stable, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs-stable; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-skk
    ];
  };
}
