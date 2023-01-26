{pkgs, ...}: {
  imports = [
    ./nix.nix
    ./node.nix
    ./rust.nix
  ];
  home.packages = with pkgs; [
    # C
    gcc
    # Deno runtime
    deno
  ];
}
