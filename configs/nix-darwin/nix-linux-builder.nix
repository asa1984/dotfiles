{ inputs, ... }:
{
  imports = [
    inputs.nix-linux-builder.darwinModules.default
  ];

  services.nix-linux-builder = {
    enable = true;
  };
}
