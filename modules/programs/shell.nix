{pkgs, ...}: {
  programs = {
    zsh.enable = true;
    git.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  environment.systemPackages = with pkgs; [
    acpi
    bottom
    btrfs-progs
    duf
    lsof
    pciutils
  ];
}
