{ pkgs, ... }: {
  imports = [
    ./browsers.nix
    ./chat.nix
    ./gtk.nix
    ./xdg.nix
    ./terminals
    ./vscode
  ];
}
