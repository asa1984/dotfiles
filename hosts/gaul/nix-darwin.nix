{
  hostname,
  inputs,
  pkgs,
  system,
  theme,
  username,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.private-modules.darwinModules.gaul

    ../../configs/nix-darwin/macos-defaults.nix
    ../../configs/nix-darwin/nix.nix
  ];

  # System
  system.stateVersion = 5;
  networking.hostName = hostname;
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
    casks = [ ];
  };

  # Misc
  programs.gnupg.agent.enable = true;
}
