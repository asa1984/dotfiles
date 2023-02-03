{pkgs, ...}: {
  imports = [
    ./audio.nix
    ./browsers.nix
    ./chat.nix
    ./gtk.nix
    ./remote.nix
    ./trust.nix
    ./xdg.nix
    ./terminals
    ./vscode
  ];
}
