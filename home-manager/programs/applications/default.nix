{ pkgs, ... }: {
  imports = [
    ./browser.nix
    ./chat.nix
    ./terminals
    ./vscode
  ];
}
