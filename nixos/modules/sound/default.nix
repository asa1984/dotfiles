_: {
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipepwire = {
    enable = true;
    alsa.enable = true;
    alsa.support32bit = true;
    pulse.enable = true;
  };
}
