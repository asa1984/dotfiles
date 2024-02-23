{
  description = "NixOS & homa-manager configurations of asa1984";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS hardware configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Rust toolchain
    rust-overlay.url = "github:oxalica/rust-overlay";

    # Key remapper
    xremap.url = "github:xremap/nix-flake";

    # nekowinston's nur (for WezTerm nightly)
    nekowinston-nur.url = "github:nekowinston/nur";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    hyprsome.url = "github:sopa0/hyprsome";

    # TUI RSS feed reader
    syndicationd.url = "github:ymgyt/syndicationd";
  };

  outputs = inputs: let
    allSystems = [
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-linux" # 64-bit x86 Linux
      "aarch64-darwin" # 64-bit ARM macOS
      "x86_64-darwin" # 64-bit x86 macOS
    ];
    forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;
  in {
    nixosConfigurations = (import ./hosts inputs).nixos;
    homeConfigurations = (import ./hosts inputs).home-manager;
    devShells = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
      scripts = with pkgs; [
        (writeScriptBin "switch-home" ''
          home-manager switch --flake ".#$@"
        '')
        (writeScriptBin "switch-nixos" ''
          sudo nixos-rebuild switch --flake ".#$@"
        '')
      ];
    in {
      default = pkgs.mkShell {
        packages = scripts;
      };
    });
  };
}
