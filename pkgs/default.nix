pkgs: {
  claude-code = pkgs.callPackage ./claude-code { };
  gh-q = pkgs.callPackage ./gh-q { };
  hypr-helper = pkgs.callPackage ./hypr-helper { };
  noto-fonts-not-variable = pkgs.callPackage ./noto-fonts-not-variable { };
  noto-fonts-cjk-sans-not-variable = pkgs.callPackage ./noto-fonts-cjk-sans-not-variable { };
  noto-fonts-cjk-serif-not-variable = pkgs.callPackage ./noto-fonts-cjk-sans-not-variable { };
}
