{
  inputs,
  pkgs,
  theme,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.Ziro;
    colorScheme = "custom";

    customColorScheme = with theme.colors; {
      text = fg;
      subtext = white;
      main = bg;
      sidebar = bg;
      player = bg;
      card = black;
      shadow = black;
      selected-row = fg;
      button = fg;
      button-active = blue;
      button-disabled = white;
      tab-active = fg;
      notification = fg;
      notification-error = red;
      misc = black;
    };

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      hidePodcasts
    ];
  };
}
