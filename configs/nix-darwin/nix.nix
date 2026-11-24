{
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
    };
    settings = {
      experimental-features = [
        "ca-derivations"
        "dynamic-derivations"
        "flakes"
        "nix-command"
        "recursive-nix"
      ];
      accept-flake-config = true;
      trusted-users = [
        "root"
        "@admin"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
        "https://cache.asa1984.dev"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "cache.asa1984.dev-2:ZDLpWsB88DIjBav8I3NSSRuBACUgljt7dP2KVkv7IDg="
      ];
      warn-dirty = false;
    };
  };
}
