{config, ...}: {
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
  services.tailscale.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false; # nixpkgs issue#180175
}
