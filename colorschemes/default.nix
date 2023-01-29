theme: rec {
  colors = import ./${theme}.nix;
  hashrgb = builtins.mapAttrs (key: value: "#${value}") colors;
}
