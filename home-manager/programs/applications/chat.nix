{ pkgs, ... }: {
  home.packages = with pkgs; [ discord slack teams ];

  # Disable discord autoupdate
  home.file = {
    ".config/discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true
      }
    '';
  };
}
