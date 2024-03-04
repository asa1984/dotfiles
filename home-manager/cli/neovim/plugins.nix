{
  pkgs,
  lib,
  ...
}: let
  # normalizeName :: String -> String
  normalizeName = name: let
    lowered = lib.toLower name;
    replaced = lib.replaceString ["-" "."] ["_" "_"] lowered;
  in
    replaced;

  # normalizePkgName :: { pname, ... } -> { pname, ... }
  normalizePkgName = pkg: {
    "${normalizeName pkg.pname}" = pkg;
  };

  # foldListToAttrs :: [ { pname, ... } ] -> {...}
  foldListToAttrs = list: builtins.foldl' (x: y: x // y) {} list;

  plugins = with pkgs.vimPlugins; [
    tokyonight-nvim

    alpha-nvim

    cmp-buffer
    cmp-cmdline
    cmp-nvim-lsp
    cmp-path
    cmp_luasnip
    vim-vsnip
    lspkind-nvim
    comment-nvim
    copilot-lua
    better-escape-nvim
    smart-splits-nvim
    comment-nvim
    nvim-autopairs
    nvim-ts-autotag
    none-ls-nvim
    typst-vim
    nvim-lspconfig
    rust-tools-nvim
    crates-nvim
    lspsaga-nvim

    twilight-nvim
    zen-mode-nvim

    heriline-nvim
  ];
in {
}
