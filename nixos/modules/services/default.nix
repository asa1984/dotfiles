_: {
  imports = [ ./xremap.nix ];

  services = {
    # Flatpak is sandbox environment to execute desktop applications
    flatpak.enable = true;
    tailscale.enable = true;
  };
}
