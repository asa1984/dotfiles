{
  # Enable aliases to be sudo’ed
  sudo = "sudo ";

  # Confirm before execute
  rm = "rm -i";
  cp = "cp -i";

  # CLI tools
  cat = "bat";
  grep = "rg";
  ls = "exa --icons --classify";
  la = "exa --all --icons --classify";
  ll = "exa --long --all --git --icons";
  tree = "exa --icons --classify --tree";

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
  gf = "git fetch";
  lgit = "lazygit";

  # Nix
  flake = "nix flake";

  # Docker
  dci = "docker run --rm -it";

  # Clipboard
  clip = "xclip -selection clipboard";
}
