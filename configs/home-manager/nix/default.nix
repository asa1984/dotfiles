{ pkgs, ... }:
{
  nix = {
    settings = {
      auto-optimise-store = pkgs.stdenv.isLinux;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      accept-flake-config = true;
    };
  };
}
