## Setup
```shell
nix-shell -p git
git clone https://github.com/ASA1984/dotfiles ~/.dotfiles
cd ~/.dotfiles

# home-manager
nix run home-manager -- switch --flake "./#nixos"

# NixOS modules
sudo nixos-rebuild switch --flake './#desktop_home'
reboot
```
