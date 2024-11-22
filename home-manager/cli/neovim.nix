{ pkgs, inputs, ... }:
let
  tools = with pkgs; [
    # Inner tools
    ## For telescope.nvim
    ripgrep

    ## Git TUI
    lazygit

    # Web
    ## HTML/CSS
    nodePackages.vscode-langservers-extracted

    ## JavaScript/TypeScript/Frameworks
    biome
    deno
    nodePackages.eslint
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodePackages."@astrojs/language-server"
    nodePackages."@tailwindcss/language-server"

    ## GraphQL
    nodePackages.graphql-language-service-cli

    # Programming languages
    ## Lua
    lua-language-server
    stylua

    ## Nix
    nil
    nixfmt-rfc-style

    ## C/C++
    clang-tools

    ## Go
    gopls

    ## Haskell
    haskell-language-server
    haskellPackages.fourmolu

    ## OCaml
    ocamlPackages.ocaml-lsp
    ocamlformat

    ## Python
    ruff
    pyright

    ## Zig
    zls

    # Configuration languages
    ## YAML
    yaml-language-server

    ## TOML
    taplo

    # Misc
    ## Bash
    nodePackages.bash-language-server

    ## Docker
    nodePackages.dockerfile-language-server-nodejs

    ## Protocol Buffers
    buf-language-server

    ## Shell
    shellcheck
    shfmt

    ## Typst
    tinymist
    typstyle
  ];
  neovimWrapper = inputs.asa1984-nvim.lib.${pkgs.system}.mkNeovimWrapper tools;
in
{
  home.packages = [ neovimWrapper ] ++ tools;
}
