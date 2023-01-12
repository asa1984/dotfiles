{ pkgs, ... }: {
  home.packages = with pkgs; [
    docker
  ];
}
