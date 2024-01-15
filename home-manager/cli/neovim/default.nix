{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./.;
    recursive = true;
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraPackages = with pkgs; [
      xsel
      ripgrep
      lazygit

      # Bash
      nodePackages.bash-language-server

      # C/C++
      clang-tools

      # CUE
      cuelsp

      # Docker
      nodePackages.dockerfile-language-server-nodejs

      # Go
      gopls

      # GraphQL
      nodePackages.graphql-language-service-cli

      # Haskell
      haskell-language-server
      haskellPackages.fourmolu

      # HTML/CSS
      nodePackages.vscode-langservers-extracted

      # JavaScript/TypeScript
      nodePackages.eslint
      nodePackages.prettier
      nodePackages.typescript-language-server
      nodePackages.svelte-language-server
      nodePackages."@tailwindcss/language-server"
      biome

      # Lua
      lua-language-server
      stylua

      # Nix
      alejandra
      nil

      # OCaml
      ocamlPackages.ocaml-lsp
      ocamlformat

      # Prisma
      nodePackages."@prisma/language-server"

      # Protocol Buffers
      buf-language-server

      # Python
      black
      pyright

      # Rust
      rust-analyzer

      # Shell
      shellcheck
      shfmt

      # Terraform
      terraform-ls

      # TOML
      taplo

      # Typst
      # typst-lsp # FIX: issue nixos/nixpkgs#273835
      typstfmt

      # Zig
      zls
    ];
  };
}
