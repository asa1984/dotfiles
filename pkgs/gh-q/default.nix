{ writeShellApplication, gh, fzf, ghq, git }:
# home-manager の programs.gh.extensions は各拡張の pname を参照するため、
# writeShellApplication の結果に pname を付与する。
(writeShellApplication {
  name = "gh-q";
  text = builtins.readFile ./gh-q.sh;
  runtimeInputs = [
    gh
    fzf
    ghq
    git
  ];
}).overrideAttrs (_: { pname = "gh-q"; })
