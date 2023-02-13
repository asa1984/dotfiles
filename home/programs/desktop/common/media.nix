{pkgs, ...}: {
  # Spotify TUI
  programs.ncspot = {
    enable = true;
  };

  services.easyeffects = {
    enable = true;
  };
  programs.obs-studio = {
    enable = true;
  };
}
