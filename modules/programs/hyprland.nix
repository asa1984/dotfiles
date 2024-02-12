{inputs, ...}: {
  imports = [inputs.hyprland.nixosModules.default];
  programs.hyprland.enable = true;

  # for xremap to work with wlroots
  services.xremap.withWlroots = true;
}
