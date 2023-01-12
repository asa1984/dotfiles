{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "ASA1984";
    userEmail = "satoasa9913@gmail.com";
  };

  programs.gh = {
    enable = true;
    editor = "nvim";
  };
}
