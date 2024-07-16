{
  inputs,
  pkgs,
  theme,
  ...
}:
{
  programs.wezterm = {
    package = inputs.wezterm.packages.${pkgs.system}.default;
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
  home.file = {
    ".config/wezterm/colors/myTheme.toml".text = theme.wezterm;

    # ranger config - enable image preview on wezterm
    ".config/ranger/rc.conf".text = ''
      set preview_images true
      set preview_images_method iterm2
    '';
  };
}
