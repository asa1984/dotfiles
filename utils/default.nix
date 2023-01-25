{ inputs, ... }:
let
  inherit (inputs) self nixpkgs home-manager;
in
{
  mkSystem =
    { hostname
    , pkgs
    ,
    }:
    nixpkgs.lib.nixosSystem {
      inherit pkgs;
      specialArgs = { inherit inputs hostname; };
      modules = [ ../nixos/profiles/${hostname} ];
    };

  mkHome =
    { pkgs
    , username
    , hostname ? null
    , colorscheme ? null
    , features ? [ ]
    ,
    }:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs username hostname; };
      modules = [ ../home-manager/profiles/${username} ];
    };
}
