{pkgs, ...}: {
  imports = [
    ./browsers.nix
    ./chat.nix
    ./gtk.nix
    ./media.nix
    ./remote.nix
    ./trust.nix
    ./xdg.nix
    ./terminals
    ./vscode
  ];
}
