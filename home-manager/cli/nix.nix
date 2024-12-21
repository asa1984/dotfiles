{ pkgs, lib, ... }:
{
  nix = {
    settings = {
      auto-optimise-store = pkgs.stdenv.isLinux;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@weel"
      ] ++ lib.optionals pkgs.stdenv.isLinux [ "@admin" ];
      accept-flake-config = true;
    };
  };
}
