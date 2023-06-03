theme: let
  removeHash = str: builtins.substring 1 (builtins.stringLength str) str;
in rec
{
  # "#RRGGBB"
  xcolors = import ./colors/${theme}.nix;
  # "RRGGBB"
  colors = builtins.mapAttrs (_: value: removeHash value) colors;
}
