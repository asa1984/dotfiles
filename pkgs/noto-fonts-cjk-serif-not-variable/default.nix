# Noto Fonts in nixpkgs are variable fonts, but Steam doesn't support them.
# Issue: https://github.com/NixOS/nixpkgs/issues/178121
# PR(unmerged): https://github.com/NixOS/nixpkgs/pull/205641
{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  nixosTests,
}:
let
  typeface = "Serif";
  version = "2.000";
  rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
  sha256 = "sha256-ajqVn+HUfqvc30bbWYnzkj0z/VD3jX+U/Rxepad6vKI=";
in
stdenvNoCC.mkDerivation {
  pname = "noto-fonts-cjk-${lib.toLower typeface}";
  inherit version;

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "noto-cjk";
    inherit rev sha256;
    sparseCheckout = [ "${typeface}/OTC" ];
  };

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/noto-cjk ${typeface}/OTC/*.ttc
  '';

  passthru.tests.noto-fonts = nixosTests.noto-fonts;

  meta = with lib; {
    description = "Beautiful and free fonts for CJK languages";
    homepage = "https://www.google.com/get/noto/help/cjk/";
    longDescription = ''
      Noto ${typeface} CJK is a ${lib.toLower typeface} typeface designed as
      an intermediate style between the modern and traditional. It is
      intended to be a multi-purpose digital font for user interface
      designs, digital content, reading on laptops, mobile devices, and
      electronic books. Noto ${typeface} CJK comprehensively covers
      Simplified Chinese, Traditional Chinese, Japanese, and Korean in a
      unified font family. It supports regional variants of ideographic
      characters for each of the four languages. In addition, it supports
      Japanese kana, vertical forms, and variant characters (itaiji); it
      supports Korean hangeul — both contemporary and archaic.
    '';
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [
      mathnerd314
      emily
    ];
  };
}
