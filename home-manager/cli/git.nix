{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "asa1984";
    userEmail = "satoasa9913@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview];
    settings = {
      editor = "nvim";
    };
  };
}
