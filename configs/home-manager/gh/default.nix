{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-dash
      gh-markdown-preview
      gh-q
    ];
  };
}
