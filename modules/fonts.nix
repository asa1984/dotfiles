{pkgs, ...}: {
  fonts = {
    fonts = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      migu
      nerdfonts
      twemoji-color-font
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif CJK JP"
          "Twitter Color Emoji"
        ];
        sansSerif = [
          "Noto Sans CJK JP"
          "Twitter Color Emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Twitter Color Emoji"
        ];
        emoji = ["Twitter Color Emoji"];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <description>Change default fonts for Steam client</description>
          <match>
            <test name="prgname">
              <string>steamwebhelper</string>
            </test>
            <test name="family" qual="any">
              <string>sans-serif</string>
            </test>
            <edit mode="prepend" name="family">
              <string>Migu 1P</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };
}
