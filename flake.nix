{
  description = "Shared configuration of asa1984's dotfiles";

  # inputs は持たない。lock はこの flake を使う側 (hosts/* や別リポジトリのホスト) が持つ。
  #
  # configs/ のモジュールは specialArgs の `inputs` から次の inputs を参照するので、
  # 使う側の flake はこれらを同じ名前で持ち、lib.makeDarwinConfig に渡す。
  #   nixpkgs, nixpkgs-stable, nix-darwin, home-manager, llm-agents,
  #   asa1984-nvim, herdr-splits, nix-linux-builder, comin
  # 使わないモジュールが参照する inputs は省いてよい。
  outputs =
    _:
    let
      # dir 直下のモジュールを { <name> = <path>; } にする (foo.nix と foo/ はどちらも foo)。
      modulesIn =
        dir:
        builtins.listToAttrs (
          map (name: {
            name =
              if builtins.match ".*\\.nix" name != null then
                builtins.substring 0 (builtins.stringLength name - 4) name
              else
                name;
            value = dir + "/${name}";
          }) (builtins.attrNames (builtins.readDir dir))
        );
    in
    {
      lib = import ./lib;

      overlays = import ./overlays;

      darwinModules = {
        default = ./modules/nix-darwin;
      }
      // modulesIn ./configs/nix-darwin;

      homeModules = {
        default = ./modules/home-manager;
      }
      // modulesIn ./configs/home-manager;
    };
}
