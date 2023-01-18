{
  # Confirm before execute
  rm = "rm -i";
  cp = "cp -i";

  # Rust cli tools
  cat = "bat";
  grep = "rg";
  ls = "exa --icons --classify";
  la = "exa --all --icons --classify";
  ll = "exa --long --all --git --icons";
  tree = "exa --icons --classify --tree";

  # Git
  g = "git";
  cdg = "cd $(git rev-parse --show-toplevel)"; # cd to git root directory
  gcommit = "git add . && git commit";
  gpush = "git add . && git commit && git push";

  # Nix-Shell
  nix-shell-unfree = "NIXPKGS_ALLOW_UNFREE=1 nix-shell";
}
