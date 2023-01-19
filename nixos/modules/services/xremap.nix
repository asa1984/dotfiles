_: {
  services.xremap = {
    serviceMode = "user";
    withHypr = true;
    # userName =
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
            C-h = "BackSpace";
          };
          application = {
            not = [ "Alacritty" "Kitty" "Wezterm" ];
          };
        }
      ];
    };
  };
}
