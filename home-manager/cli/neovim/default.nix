{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    inputs.asa1984-nvim.packages.${pkgs.system}.default
  ];
}
