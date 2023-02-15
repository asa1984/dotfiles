{pkgs, ...}: {
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      twemoji-color-font
      hackgen-nf-font

      (nerdfonts.override {fonts = ["JetBrainsMono"];})
    ];

    enableDefaultFonts = false;
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Twitter Color Emoji"];
      sansSerif = ["Noto Sans" "Twitter Color Emoji"];
      monospace = ["HackGen35 Console NFJ" "Twitter Color Emoji"];
      emoji = ["Twitter Color Emoji"];
    };
  };
}
