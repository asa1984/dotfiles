# dotfiles

asa1984's dotfiles managed by Nix (nix-darwin, home-manager).

## Project Structure

```
.
├── hosts/                      # Per-host configurations, each with its own flake
│   ├── endfield/               # Primary macOS (nix-darwin)
│   │   ├── flake.nix
│   │   ├── flake.lock
│   │   ├── home-manager.nix
│   │   └── nix-darwin.nix
│   └── gaul/                   # Sub macOS (nix-darwin)
├── configs/                    # Shared concrete settings across hosts
│   ├── home-manager/
│   └── nix-darwin/
├── modules/                    # Reusable Nix modules (option definitions only)
│   ├── home-manager/
│   └── nix-darwin/
├── lib/                        # Flake helpers (makeDarwinConfig, ...)
├── overlays/
├── pkgs/                       # Custom packages
└── themes/                     # Color schemes
```

Conventions:

- `modules/` defines options only; concrete settings go in `configs/`.
- Each host is self-contained: `just switch-darwin endfield`.
