{
  pkgs,
  colorscheme,
  ...
}: {
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

      # Formatter & Linter
      null-ls-nvim

      # Treesitter
      (nvim-treesitter.withPlugins (plugins:
        with plugins; [
          tree-sitter-css
          tree-sitter-html
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-rust
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
      # JavaScript & TypeScript
      nodePackages.typescript-language-server

      # Lua
      lua-language-server
      stylua

      # Nix
      nil
      deadnix
      alejandra
    ];

    extraConfig = ''
      colorscheme tokyonight-moon
    '';
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
