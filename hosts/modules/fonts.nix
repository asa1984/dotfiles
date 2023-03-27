{pkgs, ...}: {
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      migu
      roboto
      twemoji-color-font
      # enable asian fonts for steam
      wqy_zenhei

      nerdfonts
    ];

    fontDir.enable = true;
    enableDefaultFonts = false;
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif" "Twitter Color Emoji"];
        sansSerif = ["Noto Sans CJK JP" "Noto Sans" "Twitter Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Twitter Color Emoji"];
        emoji = ["Twitter Color Emoji"];
      };

      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <description>Change default font for Steam</description>
          <match>
            <test name="prgname"><string>steam</string></test>
            <test qual="any" name="family"><string>sans-serif</string></test>
            <edit mode="prepend" name="family">
              <string>WenQuanYi Zen Hei</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };
}
