{ pkgs, user, ... }: {
  users.users.${user} = {
    isNormalUser = user;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "audio"];
  };
}
