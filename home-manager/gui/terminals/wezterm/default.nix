{
  inputs,
  pkgs,
  theme,
  ...
}:
{
  programs.wezterm = {
    package = inputs.nekowinston-nur.packages.${pkgs.system}.wezterm-nightly;
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
