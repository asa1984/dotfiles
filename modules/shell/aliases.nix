{
  rm = "rm -i";
  cp = "cp -i";

  # Rust cli tools
  cat = "bat";
  grep = "rg";
  ls = "exa --icons --classify";
  la = "exa --all --icons --classify";
  ll = "ls --long --all --git --icons";
  
  # Git
  alias g = "git";
  cdg = "cd '$(git rev-parse --show-toplevel)'"; # cd to git root directory
}
