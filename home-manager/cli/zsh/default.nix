{
  pkgs,
  theme,
  ...
}: {
  imports = [./starship.nix];
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    autocd = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = import ./aliases.nix;

    initExtra =
      # bash
      ''
        export EDITOR="nvim"
        export NIXPKGS_ALLOW_UNFREE=1

        function mkcd() {
            mkdir -p "$1" && cd "$1"
        }

        # Fuzzy find history
        function fzf-select-history(){
            BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER")
            CURSOR=$#BUFFER
            zle reset-prompt
        }
        zle -N fzf-select-history
        bindkey '^R' fzf-select-history

        # cd to the repository managed by ghq
        function __ghq-cd() {
          cd $(ghq root)/$(ghq list | fzf)
          zle clear-screen
        }
        zle -N __ghq-cd
        bindkey '^G' __ghq-cd

        # Move cursor to the beginning of the line
        bindkey '^A' beginning-of-line

        ${theme.fzf}
      '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };
}
