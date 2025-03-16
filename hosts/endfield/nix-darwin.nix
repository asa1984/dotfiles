{
  hostname,
  inputs,
  pkgs,
  pkgs-stable,
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
  security.pam.services.sudo_local.touchIdAuth = true;

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
      "arc"
      "cursor"
      "discord"
      "minecraft"
      "modrinth"
      "orbstack"
      "parsec"
      "slack"
      "spotify"
      "zoom"
    ];
  };

  # Misc
  programs.gnupg.agent.enable = true;
}
