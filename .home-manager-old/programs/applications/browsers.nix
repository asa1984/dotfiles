{pkgs, ...}: {
  home.packages = with pkgs; [firefox];

  programs.brave = {
    enable = true;
    # Launch on XWayland because fcitx5 doesn't work on chromium apps with wayland native
    commandLineArgs = ["--enable-features=UseOzonePlatfor" "--ozone-platform=x11"];
  };
}
