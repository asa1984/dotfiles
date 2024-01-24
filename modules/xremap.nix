{
  inputs,
  username,
  ...
}: {
  imports = [inputs.xremap.nixosModules.default];
  services.xremap = {
    userName = username;
    serviceMode = "system";
    config = {
      modmap = [
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
          exact_match = true;
          application = {
            not = [
              "Alacritty.Alacritty"
              "kitty.kitty"
              "org.wezfurlong.wezterm.org.wezfurlong.wezterm"
            ];
          };
          remap = {
            C-h = "Backspace";
          };
        }
      ];
    };
  };
}
