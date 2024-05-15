{ pkgs, ... }:
{
  home.file.".config/nvim" = {
    source = ../../home-manager/cli/neovim;
    recursive = true;
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    extraPackages = with pkgs; [
      xsel
      ripgrep
      lazygit

      # C/C++
      clang-tools

      # HTML/CSS
      nodePackages.vscode-langservers-extracted

      # JavaScript/TypeScript
      nodePackages.eslint
      nodePackages.prettier
      nodePackages.typescript-language-server

      # Nix
      alejandra
      nil

      # Rust
      rust-analyzer

      # TOML
      taplo

      # Zig
      zls
    ];
  };
}
