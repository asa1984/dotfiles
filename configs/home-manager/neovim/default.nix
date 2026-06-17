{
  inputs,
  ...
}:
{
  imports = [ inputs.asa1984-nvim.homeModules.ide ];

  # asa1984.nvim ships the editor together with its language toolchains
  # (compilers, runtimes, LSPs, formatters). All languages are enabled by
  # default; disable individual ones with e.g. `programs.asa1984-nvim.languages.haskell.enable = false;`.
  programs.asa1984-nvim.enable = true;
}
