{ pkgs, ... }: {
  home.packages = with pkgs; [ discord discord-ptb slack teams-for-linux ];

  # discord setting
  # - disable auto update
  home.file = {
    ".config/discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true
      }
    '';
  };
}
