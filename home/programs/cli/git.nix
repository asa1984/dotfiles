{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "ASA1984";
    userEmail = "satoasa9913@gmail.com";
  };

  home.packages = with pkgs; [
    nodePackages.gitmoji-cli
  ];
}
