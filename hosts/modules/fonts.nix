{pkgs, ...}: {
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      migu
      nerdfonts
      twemoji-color-font
    ];
  };
}
