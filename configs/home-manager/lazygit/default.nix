{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        pagers = [
          {
            externalDiffCommand = "${pkgs.difftastic}/bin/difft --color=always";
          }
        ];
      };
    };
  };
}
