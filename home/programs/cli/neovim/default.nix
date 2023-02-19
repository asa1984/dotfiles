{pkgs, ...}: {
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Vim plugins
      quick-scope
      yuck-vim

      # Theme
      tokyonight-nvim

      # LSP
      nvim-lspconfig
      lsp_signature-nvim
      lspkind-nvim
      fidget-nvim
      # LSP: Rust
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

      # IDE
      indent-blankline-nvim
      mini-nvim
      nvim-autopairs
      nvim-colorizer-lua
      nvim-comment

      # Navigation
      nvim-hlslens
      nvim-tree-lua
      telescope-nvim
      which-key-nvim

      # UI
      lualine-nvim
      nvim-web-devicons
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
