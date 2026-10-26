# dotfiles

asa1984's dotfiles managed by Nix (nix-darwin, home-manager).

## Project Structure

```
.
├── flake.nix                   # Exports lib, overlays and modules to other flakes (no inputs)
├── hosts/                      # Per-host configurations, each with its own flake
│   └── endfield/               # Primary macOS (nix-darwin)
│       ├── flake.nix
│       ├── flake.lock
│       ├── home-manager.nix
│       └── nix-darwin.nix
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
- The root flake has no inputs. A host outside this repository takes it as an input and passes its own `inputs` to `lib.makeDarwinConfig`, so every host keeps its own lock.
