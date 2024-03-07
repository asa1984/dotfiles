{
  # nixpkgs.overlays = [outputs.overlays.additions];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
