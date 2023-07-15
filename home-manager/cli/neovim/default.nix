{pkgs, ...}: {
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
      # LSP: Rust
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
          tree-sitter-sql
          tree-sitter-toml
          tree-sitter-tsx
          tree-sitter-typescript
          tree-sitter-yaml
          tree-sitter-zig
        ]))

      # Formatter & Linter
      null-ls-nvim

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      vim-vsnip
      cmp-vsnip
      lspkind-nvim

      # IDE
      comment-nvim
      gitsigns-nvim
      indent-blankline-nvim
      nvim-autopairs
      nvim-highlight-colors
      nvim-ts-autotag
      nvim-ufo
      statuscol-nvim

      # Navigation
      nvim-hlslens
      telescope-nvim

      # UI
      alpha-nvim
      bufferline-nvim
      lualine-nvim
      noice-nvim
      nvim-tree-lua
      nvim-web-devicons

      # Vim plugins
      vim-floaterm
      yuck-vim
    ];

    extraPackages = with pkgs; [
      # for clipboard
      xclip
      xsel

      # for telescope-nvim
      ripgrep

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

      # TOML
      taplo

      # Zig
      zls
    ];

    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
