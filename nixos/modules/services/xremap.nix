{ user, ... }: {
  services.xremap = {
    userName = user;
    serviceMode = "user";
    withHypr = true;
    config = {
      modMap = [
        {
          name = "CapsLock is dead";
          remap = {
            CapsLock = "Ctrl_L";
          };
        }
      ];
      keymap = [
        {
          name = "Ctrl+H should be enabled on all apps as BackSpace";
          remap = {
            C-h = "Backspace";
          };
          application = {
            not = [ "Alacritty" "Kitty" "Wezterm" ];
          };
        }
      ];
    };
  };
}
