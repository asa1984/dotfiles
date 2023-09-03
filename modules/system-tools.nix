{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    acpi
    btrfs-progs
    lsof
    pciutils
  ];
}
