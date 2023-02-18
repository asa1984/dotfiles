{pkgs, ...}: {
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      twemoji-color-font

      (nerdfonts.override {fonts = ["JetBrainsMono"];})
    ];

    enableDefaultFonts = true;
    fontconfig.defaultFonts = {
      emoji = ["Twitter Color Emoji"];
    };
  };
}
