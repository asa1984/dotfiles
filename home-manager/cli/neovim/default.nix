{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Colorscheme
      tokyonight-nvim

      # Coding assistant
      copilot-lua

      # LSP
      nvim-lspconfig
      lspsaga-nvim
      neodev-nvim

      # Languages
      ## Rust
      rust-tools-nvim
      crates-nvim

      # Treesitter
      (nvim-treesitter.withPlugins (plugins:
        with plugins; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-css
          tree-sitter-dockerfile
          tree-sitter-go
          tree-sitter-haskell
          tree-sitter-html
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-latex
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-prisma
          tree-sitter-python
          tree-sitter-regex
          tree-sitter-rust
          tree-sitter-scss
          tree-sitter-sql
          tree-sitter-terraform
          tree-sitter-toml
          tree-sitter-tsx
          tree-sitter-typescript
          tree-sitter-yaml
          tree-sitter-zig
        ]))

      # Formatter & Linter
      null-ls-nvim

      # Syntax
      indent-blankline-nvim
      nvim-highlight-colors
      nvim-ufo
      statuscol-nvim

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      vim-vsnip
      cmp-vsnip
      lspkind-nvim
      comment-nvim
      nvim-autopairs
      nvim-ts-autotag

      # UI
      alpha-nvim
      bufferline-nvim
      gitsigns-nvim
      heirline-nvim
      neo-tree-nvim
      noice-nvim
      nvim-hlslens
      nvim-scrollbar
      nvim-web-devicons
      smart-splits-nvim
      telescope-nvim
      toggleterm-nvim
    ];

    extraPackages = with pkgs; [
      xsel
      ripgrep
      lazygit

      # Bash
      nodePackages.bash-language-server

      # C/C++
      clang-tools

      # Docker
      nodePackages.dockerfile-language-server-nodejs

      # Go
      gopls

      # Haskell
      haskell-language-server
      haskellPackages.fourmolu

      # HTML/CSS
      nodePackages.vscode-langservers-extracted

      # JavaScript/TypeScript
      nodePackages.prettier
      nodePackages.typescript-language-server
      nodePackages.svelte-language-server
      nodePackages."@tailwindcss/language-server"

      # Lua
      lua-language-server
      stylua

      # Nix
      alejandra
      deadnix
      nil
      statix

      # Prisma
      nodePackages."@prisma/language-server"

      # Python
      black
      pyright

      # Rust
      rust-analyzer
      rustfmt

      # Shell
      shellcheck
      shfmt

      # Terraform
      terraform-ls

      # TOML
      taplo

      # Zig
      zls
    ];
  };
}
