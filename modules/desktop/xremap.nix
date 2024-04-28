{ inputs, username, ... }: {
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ username ];
  users.groups.input.members = [ username ];

  imports = [ inputs.xremap.nixosModules.default ];
  services.xremap = {
    userName = username;
    serviceMode = "user";
    config = {
      modmap = [{
        name = "CapsLock is dead";
        remap = { CapsLock = "Ctrl_L"; };
      }];
      keymap = [{
        name = "Better Backspace";
        exact_match = true;
        application = {
          not = [
            "Alacritty"
            "kitty"
            "org.wezfurlong.wezterm.org.wezfurlong.wezterm"
          ];
        };
        remap = { C-h = "Backspace"; };
      }];
    };
  };
}
