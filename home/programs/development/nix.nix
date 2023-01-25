{ pkgs, ... }: {
  home.packages = with pkgs; [
    alejandra # formatter
    deadnix # scan dead code
    statix # linter
  ];

  # programs.direnv={
  #   enable=true;
  # };
}
