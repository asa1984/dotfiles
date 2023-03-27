{pkgs, ...}: {
  home.packages = with pkgs; [parsec-bin moonlight-qt remmina];
}
