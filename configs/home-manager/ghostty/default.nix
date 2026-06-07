{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    # On darwin, ghostty is installed via Homebrew cask (no nixpkgs build);
    # elsewhere, use the package from nixpkgs.
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    settings = {
      font-family = "HackGen Console NF";
      font-size = 16;
      theme = "Tokyonight Moon";
      macos-titlebar-style = "hidden";
      macos-option-as-alt = "left";
    };
  };
}
