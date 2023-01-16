{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./kitty.nix 
    ./unfree.nix
  ];
}
