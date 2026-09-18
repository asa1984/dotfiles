{
  lib,
  stdenvNoCC,
  fetchurl,
  python3,
}:
# herdr-radar (https://github.com/hhdebb/herdr-radar) が配っている、エージェントのロゴと
# 状態の記号だけを集めたフォント。私用領域の U+E1A0-U+E1B6 (ロゴ) と U+E1C0-U+E1C5 (状態) を持つ。
# herdr-glance (configs/home-manager/herdr/glance) がこの符号位置を書き、ghostty の
# font-codepoint-map でこの face に振っている (configs/home-manager/ghostty)。
#
# radar の npm パッケージには make_font 一式が入っているが、ここでは配布物の .ttf を
# バージョンを固定して取るだけにする (ロゴは各社の商標なので、dotfiles には同梱しない)。
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-agent-icons";
  version = "1.3.5";

  srcs = [
    (fetchurl {
      url = "https://raw.githubusercontent.com/hhdebb/herdr-radar/v${finalAttrs.version}/dist/HerdrAgentIconsMax-Regular.ttf";
      hash = "sha256-13kQ6k5wqG5GGLpTKfUYMPObgwR3wfuAnepwTswZn2Y=";
    })
    (fetchurl {
      url = "https://raw.githubusercontent.com/hhdebb/herdr-radar/v${finalAttrs.version}/dist/OFL.txt";
      hash = "sha256-p2q/ACxJCX0UboZ0CjEFpdAEULFZLoIKEQmoxWgM1pc=";
    })
  ];

  dontUnpack = true;

  nativeBuildInputs = [ python3.pkgs.fonttools ];

  # 状態の記号のうち、radar が調整していない 2 つを idle の輪に合わせる (resize-marks.py 参照)
  buildPhase = ''
    runHook preBuild
    python3 ${./resize-marks.py} ${builtins.elemAt finalAttrs.srcs 0} HerdrAgentIconsMax-Regular.ttf
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 HerdrAgentIconsMax-Regular.ttf $out/share/fonts/truetype/HerdrAgentIconsMax-Regular.ttf
    install -Dm444 ${builtins.elemAt finalAttrs.srcs 1} $out/share/doc/${finalAttrs.pname}/OFL.txt
    runHook postInstall
  '';

  meta = {
    description = "Agent logo and lifecycle marks from herdr-radar, as a private-use-area font";
    homepage = "https://github.com/hhdebb/herdr-radar";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
