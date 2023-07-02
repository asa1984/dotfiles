# dotfiles

ASA1984's NixOS & home-manager configurations

## Requirements

- Nix command & Flakes are enabled

## Setup

You can check all hosts with `nix flake show` or [here](https://github.com/asa1984/dotfiles/blob/xmonad/hosts/default.nix).

### NixOS modules

```nix
sudo nixos-rebuild switch --flake "./#<hostsname>"
reboot

```

### home-manager

```nix
nix run home-manager -- switch --flake "./<username>@<hostname>"
```
