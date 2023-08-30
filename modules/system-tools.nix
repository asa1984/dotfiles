{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    acpi
    btrfs
    lsof
    pciutils
  ];
}
