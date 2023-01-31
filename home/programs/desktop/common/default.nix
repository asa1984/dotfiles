{pkgs, ...}: {
  imports = [
    ./browsers.nix
    ./chat.nix
    ./gtk.nix
    ./remote.nix
    ./xdg.nix
    ./terminals
    ./vscode
  ];
}
