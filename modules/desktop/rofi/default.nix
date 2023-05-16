{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi.override {
      plugins = with pkgs; [
        rofi-emoji
        rofi-calc
      ];
    };
    font = "Hack Nerd Font 11";
  };
  home.file.".config/rofi/colors.rasi".text = ''
    * {
      background:     #222436FF;
      background-alt: #1b1d2bFF;
      foreground:     #C8d3f5FF;
      selected:       #82aaffFF;
      active:         #444a73FF;
      urgent:         #ff757fFF;
    }
  '';
  home.file.".config/rofi/launcher.rasi".source = ./launcher.rasi;
}
