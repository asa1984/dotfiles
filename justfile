# Per-host flakes live in ./hosts/<host>.
# Usage: just update endfield [input] / just switch-darwin endfield

# Update flake inputs of a host (optionally a single input)
update host input="":
    cd ./hosts/{{ host }} && nix flake update {{ input }}

# nix-darwin: apply system configuration
switch-darwin host:
    sudo nix run nix-darwin -- switch --flake ./hosts/{{ host }}#{{ host }}

# CI (check-flake.yaml) 相当のビルドをローカルで実行
build host:
    nix build ./hosts/{{ host }}#darwinConfigurations."{{ host }}".config.system.build.toplevel --no-link --print-build-logs --show-trace

# 評価だけを素早く確認する (ビルドはしない)
check host:
    nix eval ./hosts/{{ host }}#darwinConfigurations."{{ host }}".config.system.build.toplevel.drvPath --show-trace
