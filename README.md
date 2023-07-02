# dotfiles

ASA1984's NixOS & home-manager configurations

| Category | Name           | Description                   |
| -------- | -------------- | ----------------------------- |
| OS       | NixOS          | **_The Best Linux Distro_**   |
| Kernel   | XanMod         | The name is similar to XMonad |
| Shell    | ZSH + Starship | Simple & Functional           |
| Editor   | Neovim         | The only choice               |
| Terminal | Wezterm        | Practical terminal emulator   |
| WM       | XMonad         | Functional window manager     |

## Code Structure

### `hosts`

Per-host settings (e.g. hardware configurations) are defined [here](https://github.com/asa1984/dotfiles/blob/master/hosts/default.nix).

- **terra**: My primary desktop PC
- **rhodes**: My laptop
- **rhine**: VM on the Proxmox VE server

**_Tips_**: If you'd like to configure multiple environments with a single code, you should share nothing but completely reusable modules for flexibility.

### `modules`

Shared NixOS modules

### `home-manager`

- **cli**: Command-line tools

- **gui**: GUI applications used in the desktop environment

- **desktop**: The settings of XMonad and utilities for Xorg

### `themes`

The color schemes for all applications

- **tokyonight-moon**: Refer to [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)

## Setup

### Requirements

- Nix command & Flakes are enabled

### Commands

#### NixOS modules

```nix
sudo nixos-rebuild switch --flake "./#<hostsname>"
reboot

```

#### home-manager

```nix
nix run home-manager -- switch --flake "./<username>@<hostname>"
```
