update host input="":
    cd ./hosts/{{ host }} && nix flake update {{ input }}

switch-darwin host:
    sudo nix run nix-darwin -- switch --flake ./hosts/{{ host }}#{{ host }}
