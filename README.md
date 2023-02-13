# dotfiles
ASA1984's NixOS & home-manager configurations

## Setup
### Require
- Nix
- Enable Nix command & Flakes

### Command
```shell
nix shell nixpkgs#git
git clone https://github.com/ASA1984/dotfiles ~/.dotfiles
cd ~/.dotfiles

# home-manager
nix run home-manager -- switch --flake "./#asahi@prime"

# NixOS modules
sudo nixos-rebuild switch --flake './#prime'
reboot
```
