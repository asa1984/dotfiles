{ pkgs, username, ... }:
{
  nix = {
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "${username}"
      ];
      accept-flake-config = true;
    };
  };
}
