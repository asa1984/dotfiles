{pkgs, ...}: {
  home.packages = with pkgs; [deno];
}
