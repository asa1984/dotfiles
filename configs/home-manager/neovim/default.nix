{
  pkgs,
  inputs,
  ...
}:
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
    # biome
    # deno
    # nodePackages.eslint
    # nodePackages.prettier
    # nodePackages.typescript-language-server
    # nodePackages."@astrojs/language-server"
    # nodePackages."@tailwindcss/language-server"

    ## GraphQL
    # nodePackages.graphql-language-service-cli

    # Programming languages
    ## Lua
    lua-language-server
    stylua

    ## Nix
    nil
    nixfmt

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
    dockerfile-language-server

    ## Protocol Buffers
    buf

    ## Shell
    shellcheck
    shfmt

    ## Typst
    tinymist
    typstyle
  ];
in
{
  home.packages = [
    inputs.asa1984-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
  ]
  ++ tools;

  programs.zsh.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
