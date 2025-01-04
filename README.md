# dotfiles

asa1984's NixOS & home-manager configurations

| Category | Name           | Description                                             |
| -------- | -------------- | ------------------------------------------------------- |
| OS       | NixOS          | **_The Best Linux Distro_**                             |
| Kernel   | XanMod         | How to pronounce?                                       |
| Shell    | zsh + Starship | Simple & Stylish                                        |
| Editor   | Neovim         | [asa1984.nvim](https://github.com/asa1984/asa1984.nvim) |
| Terminal | WezTerm        | Practical terminal emulator                             |
| WM       | Hyprland       | Beautiful animation & Nix integration                   |

![desktop](./_image/desktop.png)

## 🏗️ File Structure

### `hosts`

Per-host configurations

| Name   | Description           |
| ------ | --------------------- |
| terra  | My primary desktop PC |
| rhodes | My laptop (HP Envy13) |
| rhine  | VM on the Proxmox VE  |
| gaul   | M1 Macbook Air        |

### `modules`

NixOS / home-manager / nix-darwin modules

### `configs`

Shared configurations for NixOS / home-manager / nix-darwin

### `pkgs`

User packages

| Name                      | Description                               |
| ------------------------- | ----------------------------------------- |
| gh-q                      | `gh` extension to fuzzy-find GitHub repos |
| hypr-helper               | My hyprland helper tool                   |
| noto-fonts-\*not-variable | Noto Sans (Not variable version)          |

### `themes`

The color schemes

- **tokyonight-moon**: Refer to [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)

## 🚀 Setup

### Requirements

- Nix command & Flakes are enabled

### Commands

#### NixOS

```nix
nix develop
nh os switch .
reboot
```

#### home-manager

```nix
nix develop
nh home switch .
```

### nix-darwin

```nix
nix run nix-darwin -- switch --flake .
```

## 📖 References

- [nixypanda/dotfiles](https://github.com/nixypanda/dotfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [natsukium/dotfiles](https://github.com/natsukium/dotfiles)
