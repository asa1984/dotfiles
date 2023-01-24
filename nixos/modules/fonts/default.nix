{pkgs, ...}: {
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    twemoji-color-font
    hackgen-nf-font
  ];
}
