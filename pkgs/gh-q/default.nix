{ writeShellApplication, gh, fzf, ghq, git }:
writeShellApplication {
  name = "gh-q";
  text = builtins.readFile ./gh-q.sh;
  runtimeInputs = [
    gh
    fzf
    ghq
    git
  ];
}
