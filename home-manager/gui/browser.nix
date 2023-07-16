{
  programs = {
    firefox.enable = true;
    google-chrome.enable = true;
    vivaldi = {
      enable = true;
      commandLineArgs = [ "--enable-features=WebUIDarkMode" "--force-dark-mode" ];
    };
  };
}
