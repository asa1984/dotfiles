{ pkgs, ... }: {
  imports = [
    ./c.nix
    ./deno.nix
    ./nix.nix
    ./node.nix
    ./rust.nix
  ];
}
