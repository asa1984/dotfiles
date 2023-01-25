{ pkgs, ... }: {
  imports = [
    ./chat.nix
    ./gtk.nix
    ./xdg.nix
    ./browsers
    ./terminals
    ./vscode
  ];
}
