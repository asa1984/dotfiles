# dotfiles

asa1984's nix-darwin & home-manager configurations

| Category | Name           | Description                                             |
| -------- | -------------- | ------------------------------------------------------- |
| OS       | macOS          |                                                         |
| Shell    | zsh + Starship | Simple & Stylish                                        |
| Editor   | Neovim         | [asa1984.nvim](https://github.com/asa1984/asa1984.nvim) |
| Terminal | WezTerm        | Practical terminal emulator                             |

## 🏗️ File Structure

Each host has its own self-contained flake (`hosts/<host>/flake.nix` + `flake.lock`).

### `hosts`

Per-host configurations

| Name     | Description    |
| -------- | -------------- |
| gaul     | M1 Macbook Air |
| endfield | My primary macOS |

### `modules`

Reusable Nix modules (option definitions only)

### `configs`

Shared concrete settings for home-manager / nix-darwin

### `pkgs`

User packages

| Name                      | Description                               |
| ------------------------- | ----------------------------------------- |
| gh-q                      | `gh` extension to fuzzy-find GitHub repos |
| noto-fonts-\*not-variable | Noto Sans (Not variable version)          |

### `themes`

The color schemes

- **tokyonight-moon**: Refer to [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)

## 🚀 Setup

### Requirements

- Nix command & Flakes are enabled
- [`just`](https://github.com/casey/just) for the shortcuts below

### Commands

#### nix-darwin

```sh
just switch-darwin endfield
```

## 📖 References

- [nixypanda/dotfiles](https://github.com/nixypanda/dotfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [natsukium/dotfiles](https://github.com/natsukium/dotfiles)
