{pkgs, ...}: {
  home.packages = with pkgs; [discord discord-ptb slack teams-for-linux];

  # discord setting
  # - disable auto update
  home.file = {
    ".config/discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true,
        "DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING": true
      }
    '';
  };
}
