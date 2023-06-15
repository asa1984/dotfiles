{pkgs, ...}: {
  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  programs.noisetorch.enable = true;

  # Fonts
  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      migu
      roboto
      twemoji-color-font
      wqy_zenhei # enable asian fonts for steam
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

  # Security - Some apps require gnome-keyring (e.g. VSCode)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
  };

  # Apps
  ## Flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
}
