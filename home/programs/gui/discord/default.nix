{
  home.file = {
    ".config/discord/settings.json".text = builtins.readFile ./settings.json;
  };
  programs.discocss = {
    enable = true;
    css = builtins.readFile ./custom.css;
  };
}
