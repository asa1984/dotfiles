{ pkgs, ... }: {
  home.packages = with pkgs; {
    brave
      chromium
      firefox
      google-chrome
      };
      }
