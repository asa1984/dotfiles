{
  default = final: _prev: import (../pkgs) final;

  bumps = import ./bumps.nix;

  fixes = import ./fixes.nix;
}
