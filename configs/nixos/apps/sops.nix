{
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../../secrets/default.yaml;
    age = {
      sshKeyPaths = builtins.map (key: key.path) config.services.openssh.hostKeys;
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
