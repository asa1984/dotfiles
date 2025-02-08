{
  hostname,
  inputs,
  pkgs,
  theme,
  username,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ../../configs/nix-darwin/macos-defaults.nix
    ../../configs/nix-darwin/nix.nix
  ];

  # System
  system.stateVersion = 5;
  networking.hostName = hostname;
  users.users.${username}.home = "/Users/${username}";
  fonts.packages = with pkgs; [ hackgen-nf-font ];
  security.pam.enableSudoTouchIdAuth = true;

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import ./home-manager.nix;
    extraSpecialArgs = {
      inherit
        hostname
        inputs
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
      "arc"
      "cursor"
      "discord"
      "orbstack"
      "slack"
      "spotify"
    ];
  };

  # Misc
  programs.gnupg.agent.enable = true;
}
