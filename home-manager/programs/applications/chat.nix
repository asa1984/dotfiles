{ pkgs, ... }: {
  home.packages = with pkgs; [ discord discord-ptb slack teams teams-for-linux ];

  # Disable discord autoupdate
  home.file = {
    ".config/discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true
      }
    '';
  };
}
