# Per-host flakes live in ./hosts/<host>.
# Usage: just update endfield [input] / just switch-darwin endfield

# Update flake inputs of a host (optionally a single input)
update host input="":
    cd ./hosts/{{ host }} && nix flake update {{ input }}

# nix-darwin: apply system configuration
switch-darwin host:
    sudo nix run nix-darwin -- switch --flake ./hosts/{{ host }}#{{ host }}
