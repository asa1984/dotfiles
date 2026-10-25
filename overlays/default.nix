_inputs: {
  default = final: _prev: import (../pkgs) final;

  bumps = import ./bumps.nix;
}
