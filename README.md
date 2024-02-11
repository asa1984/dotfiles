# dotfiles

asa1984's NixOS & home-manager configurations

| Category | Name           | Description                 |
| -------- | -------------- | --------------------------- |
| OS       | NixOS          | **_The Best Linux Distro_** |
| Kernel   | XanMod         | How to pronounce?           |
| Shell    | ZSH + Starship | Simple & Functional         |
| Editor   | Neovim         | The only choice             |
| Terminal | Wezterm        | Practical terminal emulator |
| WM       | Hyprland       | Beautiful window manager    |

![desktop](./_image/desktop.png)

## 🏗️ File Structure

### `hosts`

Per-host settings (e.g. hardware configurations)

- **terra**: My primary desktop PC
- **rhodes**: My laptop (HP Envy13)
- **rhine**: VM on the Proxmox VE server

### `modules`

Shared NixOS modules

### `home-manager`

- **cli**: Command-line tools

- **gui**: GUI applications used in the desktop environment

- **desktop**: Desktop environments

### `themes`

The color schemes for all applications

- **tokyonight-moon**: Refer to [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)

## 🚀 Setup

### Requirements

- Nix command & Flakes are enabled

### Commands

#### direnv

#### NixOS modules

```nix
nix develop
switch-nixos "<hostname>" # NixOS modules
reboot

```

#### home-manager

```nix
nix develop
switch-home "<username>@<hostname>"
```

## 📖 Reference

- [sherubthakur/dotfiles](https://github.com/sherubthakur/dotfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
