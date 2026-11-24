# nixpkgs のパッケージがこちらの環境でビルドに失敗するときの一時的な回避策を置く。
#
# nixpkgs 側で対象のバージョンが変わると assert で評価が止まるので、そのときは
# 回避策なしでビルドできるか確かめてから該当するエントリを消す。
final: prev:
let
  inherit (prev) lib;

  # pkg が version のままであることを確かめてから f pkg を返す。
  pin =
    pkg: version: f:
    assert lib.assertMsg (pkg.version == version) ''
      nixpkgs now ships ${pkg.name} (was ${version}).
      Check whether it builds without its override in overlays/fixes.nix and drop it.
    '';
    f pkg;
in
{
  # vimPlugins の lua 製プラグインは neovim-unwrapped.lua.pkgs (= luajit.pkgs) から作られる。
  # vimPlugins 側の derivation は lua 側の derivation を丸ごと参照しているので、
  # lua のパッケージセットで上書きしないとテストが走ってしまう。
  luajit_2_1 = prev.luajit_2_1.override {
    self = final.luajit_2_1;
    packageOverrides = _luafinal: luaprev: {
      # darwin 向けに有効化された spec/integration/lsp_spec.lua が neovim 0.12 で落ちる。
      rustaceanvim = pin luaprev.rustaceanvim "9.2.2-2" (p: p.overrideAttrs { doCheck = false; });
    };
  };
}
