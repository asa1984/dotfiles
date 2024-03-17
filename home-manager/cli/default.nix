{ pkgs, ... }: {
  imports = [
    ./neovim
    ./zsh
    ./development.nix
    ./direnv.nix
    ./git.nix
    ./nix.nix
    ./tools.nix
  ];
}
