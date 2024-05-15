{ pkgs, ... }:
{
  imports = [
    ../../home-manager/cli/direnv.nix
    ../../home-manager/cli/git.nix
    ../../home-manager/cli/nix.nix
    ../../home-manager/cli/tools.nix

    ../../home-manager/cli/neovim
    ../../home-manager/cli/zsh

    ./neovim.nix
  ];

  home.packages = with pkgs; [
    # Languages
    ## C
    gcc

    ## JS/TS
    nodePackages_latest.nodejs
    nodePackages_latest.pnpm
    deno
    bun

    ## Rust
    rust-bin.stable.latest.default
  ];
}
