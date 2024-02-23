{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
      accept-flake-config = true;

      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://syndicationd.cachix.org"
        "https://helix.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "syndicationd.cachix.org-1:qeH9C3xDqR831xEuDcfhGEUslMMjGroPPMOwiZfyiJQ="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
