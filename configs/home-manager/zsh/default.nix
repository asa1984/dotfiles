{
  config,
  pkgs,
  theme,
  ...
}:
{
  home.packages = with pkgs; [
    bat
    eza
    fzf
    ripgrep
  ];

  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh";

    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.ignoreAllDups = true;

    shellAliases = {
      # Enable aliases to be sudo’ed
      sudo = "sudo ";

      # Confirm before execute
      rm = "rm -i";
      cp = "cp -i";

      # Core
      cat = "bat";
      grep = "rg";
      ls = "eza --icons always --classify always";
      la = "eza --icons always --classify always --all ";
      ll = "eza --icons always --long --all --git ";
      tree = "eza --icons always --classify always --tree";

      # cd
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      cdg = "cd $(git rev-parse --show-toplevel)"; # cd to git root directory
      cdtemp = "cd $(mktemp -d)"; # cd to a temp directory

      # Git
      g = "git";
      ga = "git add .";
      gc = "git commit";
      gac = "git add . && git commit";
      gacp = "git add . && git commit && git push";
      gco = "git checkout";
      gsw = "git switch";
      gswc = "git switch -c";
      gcd = "cd $(ghq root)/$(ghq list | fzf)"; # cd to a git repository managed by ghq
      lgit = "lazygit";

      # Nix
      flake = "nix flake";

      # Docker
      dci = "docker run --rm -it";

      # Clipboard
      clip = "xclip -selection clipboard";
    };

    initContent =
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
          REPOSITORY=$(ghq list | fzf)
          # If the user did not select anything, return 1
          if [ -z "$REPOSITORY" ]; then
            return 1
          fi
          cd "$(ghq root)/$REPOSITORY"
          zle clear-screen
        }
        zle -N __ghq-cd
        bindkey '^G' __ghq-cd

        # Move cursor to the beginning of the line
        bindkey '^A' beginning-of-line

        ${theme.fzf}
      '';
  };
}
