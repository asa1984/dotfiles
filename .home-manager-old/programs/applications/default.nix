{pkgs, ...}: {
  imports = [
    ./browsers.nix
    ./chat.nix
    ./terminals
    ./vscode
  ];
}
