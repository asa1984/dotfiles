{
  # Enable aliases to be sudo’ed
  sudo = "sudo ";

  # Confirm before execute
  rm = "rm -i";
  cp = "cp -i";

  # Core
  cat = "bat";
  grep = "rg";
  ls = "eza --icons --classify";
  la = "eza --all --icons --classify";
  ll = "eza --long --all --git --icons";
  tree = "eza --icons --classify --tree";

  # cd
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
  "....." = "cd ../../../..";
  cdg = "cd $(git rev-parse --show-toplevel)"; # cd to git root directory
  cdtemp = "cd $(mktemp -d)"; # cd to a temp directory

  # Git
  g = "git";
  ga = "git add .";
  gc = "git commit";
  gac = "git add . && git commit";
  gacp = "git add . && git commit && git push";
  gco = "git checkout";
  gsw = "git switch";

  gcd = "cd $(ghq root)/$(ghq list | fzf)"; # cd to a git repository managed by ghq

  lgit = "lazygit";

  # Nix
  flake = "nix flake";

  # Docker
  dci = "docker run --rm -it";

  # Clipboard
  clip = "xclip -selection clipboard";
}
