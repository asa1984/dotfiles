{pkgs, ...}: {
  imports = [
    ./browsers.nix
    ./chat.nix
    ./gtk.nix
    ./music.nix
    ./remote.nix
    ./xdg.nix
    ./terminals
    ./vscode
  ];
}
