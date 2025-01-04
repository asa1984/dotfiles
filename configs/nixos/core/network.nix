{ hostname, ... }:
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
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

  # nixpkgs issue#180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
