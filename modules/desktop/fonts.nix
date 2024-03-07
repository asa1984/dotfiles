{
  inputs,
  pkgs,
  ...
}: let
  myPackages = inputs.self.outputs.packages.${pkgs.system};
in {
  fonts = {
    packages =
      (with pkgs; [
        noto-fonts-emoji
        nerdfonts
      ])
      ++ (with myPackages; [
        # Noto Fonts in nixpkgs are variable font, but Steam doesn't support it
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ]);
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
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
