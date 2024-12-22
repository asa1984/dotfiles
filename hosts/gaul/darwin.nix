{
  inputs,
  pkgs,
  username,
  hostname,
  system,
  ...
}:
let
  private-modules = builtins.getFlake "github:asa1984/private-modules/718b83e5ae0b0165ef340e3992aced8cae1afa74";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    private-modules.darwinModules.gaul
  ];

  # System
  system.stateVersion = 5;
  networking.hostName = "gaul";
  users.users.${username}.home = "/Users/${username}";

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import ./home-manager.nix;
    extraSpecialArgs = {
      inherit
        hostname
        inputs
        private-modules
        username
        ;
      theme = (import ../../themes) "tokyonight-moon";
    };
  };

  # Nix
  services.nix-daemon.enable = true;
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
        "nix-command"
        "flakes"
      ];
      accept-flake-config = true;
      trusted-users = [
        "root"
        "@admin"
      ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      warn-dirty = false;
    };
  };
  nixpkgs = {
    overlays = [ inputs.fenix.overlays.default ];
    hostPlatform = system;
    config.allowUnfree = true;
  };

  # macOS
  security.pam.enableSudoTouchIdAuth = true;
  fonts.packages = with pkgs; [ hackgen-nf-font ];
  system = {
    defaults = {
      CustomUserPreferences."com.apple.AppleMultitouchTrackpad".DragLock = true;
      dock = {
        autohide = true;
        largesize = 64;
        magnification = true;
        mineffect = "scale";
        show-recents = false;
        tilesize = 50;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Misc
  programs.gnupg.agent.enable = true;
}
