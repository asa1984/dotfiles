{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          externalDiffCommand = "${pkgs.difftastic}/bin/difft --color=always";
        };
      };
    };
  };
}
