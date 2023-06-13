{theme, ...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
  home.file = {
    ".config/wezterm/colors/myTheme.toml".text = theme.wezterm;
  };
}
