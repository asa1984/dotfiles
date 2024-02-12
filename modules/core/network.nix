{
  config,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # nixpkgs issue#180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
