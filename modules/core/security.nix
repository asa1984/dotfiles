{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/default.yaml;
    age = {
      sshKeyPaths = builtins.map (key: key.path) config.services.openssh.hostKeys;
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Allow members of the wheel group to run sudo without a password
  security.sudo.wheelNeedsPassword = false;
}
