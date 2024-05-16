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

    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Remote deployment
    deploy-rs.url = "github:serokell/deploy-rs";

    # My personal pre-configured Neovim
    asa1984-nvim = {
      url = "github:asa1984/asa1984.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchain
    fenix.url = "github:nix-community/fenix";

    # Key remapper
    xremap.url = "github:xremap/nix-flake";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprsome.url = "github:sopa0/hyprsome";

    # TUI RSS feed reader
    syndicationd.url = "github:ymgyt/syndicationd";

    # nekowinston's NUR (for wezterm-nightly)
    nekowinston-nur.url = "github:nekowinston/nur";
  };

  outputs =
    inputs:
    let
      allSystems = [
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-linux" # 64-bit x86 Linux
        "aarch64-darwin" # 64-bit ARM macOS
        "x86_64-darwin" # 64-bit x86 macOS
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;
    in
    {
      packages = forAllSystems (system: import ./pkgs inputs.nixpkgs.legacyPackages.${system});

      nixosConfigurations = (import ./hosts inputs).nixos;
      homeConfigurations = (import ./hosts inputs).home-manager;

      deploy = {
        sshUser = "asahi";
        user = "root";
        nodes = {
          rhine = {
            hostname = "rhine";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.rhine;
            };
          };
        };
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          formatters = with pkgs; [
            nixfmt-rfc-style
            rustfmt
            stylua
            taplo
          ];
          scripts = [
            (pkgs.writeScriptBin "update-input" ''
              nix flake lock --override-input "$1" "$2" 
            '')
          ];
        in
        {
          default = pkgs.mkShell { packages = ([ pkgs.nh ]) ++ formatters ++ scripts; };
        }
      );
      formatter = forAllSystems (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          formatters = with pkgs; [
            nixfmt-rfc-style
            rustfmt
            stylua
            taplo
          ];
          format = pkgs.writeScriptBin "format" ''
            PATH=$PATH:${pkgs.lib.makeBinPath formatters}
            ${pkgs.treefmt}/bin/treefmt --config-file ${./treefmt.toml}
          '';
        in
        format
      );
    };
}
