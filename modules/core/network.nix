{ config, hostname, ... }:
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # nixpkgs issue#180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
