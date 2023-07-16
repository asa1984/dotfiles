{
  description = "XMonad config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "XMonad dev env";
      shell = { pkgs }:
        pkgs.mkShell {
          buildInputs = with pkgs; [
            (ghc.withPackages (ps:
              with ps; [
                xmonad
                xmonad-contrib
                xmonad-extras
                haskell-language-server
              ]))
          ];
        };
    };
}
