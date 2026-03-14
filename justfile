update host:
    cd ./hosts/{{ host }} && nix flake update

switch-darwin host:
    sudo nix run nix-darwin -- switch --flake ./hosts/{{ host }}
