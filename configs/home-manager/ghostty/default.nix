{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    # On darwin, ghostty is installed via Homebrew cask (no nixpkgs build);
    # elsewhere, use the package from nixpkgs.
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    settings = {
      font-family = "HackGen Console NF";
      font-size = 16;
      # herdr のサイドバー (herdr-glance) が書く私用領域の符号位置を、専用フォントで描く。
      # U+E1A0-U+E1B6 がエージェントのロゴ、U+E1C0-U+E1C5 が状態の記号 (pkgs/herdr-agent-icons)。
      font-codepoint-map = "U+E1A0-U+E1B6,U+E1C0-U+E1C5=Herdr Agent Icons Max";
      theme = "Tokyonight Moon";
      macos-titlebar-style = "hidden";
      macos-option-as-alt = "left";
    };
  };
}
