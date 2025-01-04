# Noto Fonts in nixpkgs are variable fonts, but Steam doesn't support them.
# Issue: https://github.com/NixOS/nixpkgs/issues/178121
# PR(unmerged): https://github.com/NixOS/nixpkgs/pull/205641
{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:
let
  pname = "noto-fonts";
  weights = "{Regular,Bold,Light,Italic,BoldItalic,LightItalic}";
in
stdenvNoCC.mkDerivation {
  inherit pname;
  version = "2020-01-23";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "noto-fonts";
    rev = "f4726a2ec36169abd02a6d8abe67c8ff0236f6d8";
    sha256 = "0zc1r7zph62qmvzxqfflsprazjf6x1qnwc2ma27kyzh6v36gaykw";
  };

  installPhase = ''
    # We copy in reverse preference order -- unhinted first, then
    # hinted -- to get the "best" version of each font while
    # maintaining maximum coverage.
    #
    # TODO: install OpenType, variable versions?
    local out_ttf=$out/share/fonts/truetype/noto
    install -m444 -Dt $out_ttf phaseIII_only/unhinted/ttf/*/*-${weights}.ttf
    install -m444 -Dt $out_ttf phaseIII_only/hinted/ttf/*/*-${weights}.ttf
    install -m444 -Dt $out_ttf unhinted/*/*-${weights}.ttf
    install -m444 -Dt $out_ttf hinted/*/*-${weights}.ttf
  '';

  meta = with lib; {
    description = "Beautiful and free fonts for many languages";
    homepage = "https://www.google.com/get/noto/";
    longDescription = ''
      When text is rendered by a computer, sometimes characters are
      displayed as “tofu”. They are little boxes to indicate your device
      doesn’t have a font to display the text.

      Google has been developing a font family called Noto, which aims to
      support all languages with a harmonious look and feel. Noto is
      Google’s answer to tofu. The name noto is to convey the idea that
      Google’s goal is to see “no more tofu”.  Noto has multiple styles and
      weights, and freely available to all.

      This package also includes the Arimo, Cousine, and Tinos fonts.
    '';
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [
      mathnerd314
      emily
    ];
  };
}
