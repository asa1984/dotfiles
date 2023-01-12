{ pkgs, ... }:
{
  home.packages = with pkgs; [
    discord
    slack
    brave
    parsec-bin
    vscode
  ];
}
