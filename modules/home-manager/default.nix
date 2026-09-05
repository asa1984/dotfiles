# home-manager modules: option definitions (and external option sources) only.
# Concrete settings live in ../../configs/home-manager/.
{ inputs, ... }:
{
  imports = [
    # asa1984.nvim ships the editor together with its language toolchains
    # (compilers, runtimes, LSPs, formatters), replacing the old development module.
    inputs.asa1984-nvim.homeModules.ide

    ./services/keybase-service.nix
  ];
}
