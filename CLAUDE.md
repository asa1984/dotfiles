# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is asa1984's comprehensive dotfiles repository managing NixOS, macOS (nix-darwin), and home-manager configurations using Nix Flakes. The repository supports multiple hosts across different platforms and architectures.

## Common Commands

### System Management

**NixOS systems:**
```bash
nix develop
nh os switch .
```

**macOS systems (nix-darwin):**
```bash
nix run nix-darwin -- switch --flake .
```

**Home Manager (user configs):**
```bash
nix develop
nh home switch .
```

### Development & Maintenance

**Enter development shell:**
```bash
nix develop
```

**Update packages:**
```bash
task update
```

**Format code:**
```bash
nix fmt
```

**Deploy to remote systems:**
```bash
nix run .#deploy
```

### Testing & Validation

**Check flake:**
```bash
nix flake check
```

**Build specific configurations:**
```bash
nix build .#nixosConfigurations.terra.config.system.build.toplevel
nix build .#darwinConfigurations.gaul.system
nix build .#homeConfigurations."asahi@terra".activationPackage
```

## Architecture

### Multi-Platform Structure

The repository is organized around **hosts** in `/hosts/` directory:
- **terra, rhodes, rhine**: NixOS systems (x86_64-linux)
- **gaul, endfield**: macOS systems (aarch64-darwin)

Each host contains:
- `nixos.nix` or `nix-darwin.nix` (system-level config)
- `home-manager.nix` (user-level config)  
- `hardware-configuration.nix` (NixOS only)

### Modular Design

**`/modules/`**: Reusable modules for each platform
- `nixos/` - System modules for NixOS
- `nix-darwin/` - System modules for macOS
- `home-manager/` - User environment modules

**`/configs/`**: Shared configurations organized by platform
- Contains implementations for desktop environments, applications, and services

**`/pkgs/`**: Custom packages
- `gh-q` - GitHub CLI extension
- `hypr-helper` - Hyprland helper (Rust)
- `claude-code` - Claude Code CLI
- Custom font packages

### Key Technologies

- **Nix Flakes** for reproducible configurations
- **SOPS + Age** for secrets management (see `.sops.yaml`)
- **deploy-rs** for remote deployment
- **treefmt-nix** for code formatting
- **Hyprland** (Linux) / **macOS** window management
- **WezTerm** terminal + **Neovim** editor stack

### Theme System

Centralized theming in `/themes/` with **tokyonight-moon** as the current theme. Colors are provided in multiple formats for cross-application consistency.

## Development Notes

- The repository uses **input following** to avoid dependency conflicts
- **Taskfile.yaml** provides automation for common tasks like package updates
- **Pre-commit hooks** enforce code quality (shellcheck, treefmt)
- **GitHub Actions** automate flake input updates
- Helper functions in `/lib/default.nix` abstract platform-specific configuration patterns

## Secrets Management

SOPS-encrypted secrets use Age keys for **terra** and **rhine** hosts. Secrets are managed in `secrets/` directory and automatically decrypted during activation.