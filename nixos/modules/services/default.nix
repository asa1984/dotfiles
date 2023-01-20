_: {
  imports = [ ./xremap.nix ];

  services = {
    # Flatpak is sandbox environment to execute desktop applications
    flatpak.enabel = true;
    tailscale.enable = true;
  };
}
