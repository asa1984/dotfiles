{ pkgs, ... }:
{
  fonts = {
    packages = (
      with pkgs;
      [
        nerd-fonts.hack
        nerd-fonts.jetbrains-mono
        noto-fonts-emoji

        # Noto Fonts series in nixpkgs are variable font, but Steam doesn't support variable font.
        noto-fonts-cjk-sans-not-variable
        noto-fonts-cjk-serif-not-variable
        noto-fonts-not-variable
      ]
    );
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans CJK JP"
          "Noto Color Emoji"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
