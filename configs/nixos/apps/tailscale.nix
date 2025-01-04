{ config, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
