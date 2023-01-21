_: {
  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      modules-center = [ "clock" ];
    }];
    style = builtins.readFile ./style.css;
  };
}
