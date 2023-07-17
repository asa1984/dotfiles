{pkgs, ...}: {
  #  home.file = {
  #    ".config/discord/settings.json".text = builtins.readFile ./settings.json;
  #  };
  home.packages = with pkgs; [
    discord
    discord-ptb
  ];
}
