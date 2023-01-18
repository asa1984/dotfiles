{ pkgs, ... }: {
  home.packages = with pkgs; [ discord slack teams ];
}
