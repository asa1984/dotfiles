# pkgs: (pkgs.callPackage ./noto-fonts.nix {})
pkgs: {
  noto-fonts = pkgs.callPackage ./noto-fonts.nix { };
  noto-fonts-cjk-sans = pkgs.callPackage ./noto-fonts-cjk-sans.nix { };
  noto-fonts-cjk-serif = pkgs.callPackage ./noto-fonts-cjk-serif.nix { };
}
