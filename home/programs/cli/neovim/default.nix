{pkgs, ...}: {
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Theme
      tokyonight-nvim

      # Fuzzy Finder
      telescope-nvim

      # LSP
      nvim-lspconfig
      lspkind-nvim
      # Rust
      rust-tools-nvim
      crates-nvim

      # Formatter & Linter
      null-ls-nvim

      # Treesitter
      (nvim-treesitter.withPlugins (plugins:
        with plugins; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-css
          tree-sitter-dockerfile
          tree-sitter-html
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-latex
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-python
          tree-sitter-regex
          tree-sitter-nix
          tree-sitter-rust
          tree-sitter-scss
          tree-sitter-sql
          tree-sitter-sql
          tree-sitter-tsx
          tree-sitter-typescript
          tree-sitter-yaml
        ]))

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      vim-vsnip
      cmp-vsnip

      # Misc
      nvim-autopairs
      nvim-comment
    ];

    extraPackages = with pkgs; [
      # JavaScript/TypeScript
      nodePackages.typescript-language-server

      # Lua
      lua-language-server
      stylua

      # Markdown
      nodePackages.markdownlint-cli

      # Nix
      alejandra
      deadnix
      nil
      statix

      # Rust
      rust-analyzer
      rustfmt
    ];

    extraConfig = ''
      colorscheme tokyonight-moon
    '';
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
