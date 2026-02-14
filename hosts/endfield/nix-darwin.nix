{
  hostname,
  inputs,
  pkgs-stable,
  theme,
  username,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ../../configs/nix-darwin/macos-defaults.nix
    ../../configs/nix-darwin/misc.nix
    ../../configs/nix-darwin/nix.nix
  ];

  # System
  system.stateVersion = 5;
  networking.hostName = hostname;
  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import ./home-manager.nix;
    extraSpecialArgs = {
      inherit
        hostname
        inputs
        pkgs-stable
        theme
        username
        ;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    casks = [
      "1password"
      "ableton-live-lite"
      "arc"
      "azookey"
      "blender"
      "claude"
      "cursor"
      "discord"
      "discord@ptb"
      "ghostty"
      "google-chrome"
      "minecraft"
      "modrinth"
      "orbstack"
      "parsec"
      "slack"
      "spotify"
      "steam"
      "zoom"
    ];
  };

  # Misc
  programs.gnupg.agent.enable = true;
  services.tailscale.enable = true;
}
