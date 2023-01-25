{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./node.nix
    ./rust.nix
  ];
  home.packages = with pkgs; [
    # C lang
    gcc

    # Deno runtime
    deno

    # Nix
    alejandra # formatter
  ];
}
