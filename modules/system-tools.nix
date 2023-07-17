{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    acpi
    lsof
    pciutils
  ];

  services.upower.enable = true;
}
