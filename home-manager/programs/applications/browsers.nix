{ pkgs, ... }: {
  home.packages = with pkgs; [
    brave
    chromium
    firefox
    google-chrome
  ];

  # Launch chromium apps on XWayland
  home.file = {
    ".config/chromium-flags.conf".text=''
      --enable-features=UseOzonePlatform
      --ozone-platform=x11
    '';
  };
}
