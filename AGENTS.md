# dotfiles

asa1984's dotfiles managed by Nix (NixOS, nix-darwin, home-manager).

## Project Structure

```
.
├── flake.nix                   # Nix entry point
├── configs/                    # Common settings across hosts
│   ├── home-manager/
│   ├── nix-darwin/
│   └── nixos/
├── hosts/                      # Per-host configurations
│   ├── endfiels/               # Primary macOS
│   │   ├── flake.nix           # Per-host entry point
│   │   ├── home-manager.nix
│   │   └── nix-darwin.nix
│   └── gaul/                   # Sub macOS
├── modules/                    # Reusable nix modules
│   ├── home-manager/           # home-manager modules
│   ├── nix-darwin/             # nix-darwin modules
│   └── nixos/                  # NixOS modules
└── .claude/rules/              # Path-specific rules
```
