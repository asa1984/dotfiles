{
  programs.git = {
    enable = true;
    userName = "asa1984";
    userEmail = "satoasa9913@gmail.com";
    signing = {
      key = "D6B5DF95C5360AE9";
      signByDefault = false;
    };
    extraConfig = {
      init.defaultBranch = "main";
      commit.gpgsign = false;
      merge.conflictStyle = "diff3";
      rebase.autoSquash = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
    ignores = [
      ".direnv"
      ".devenv"
      ".neoconf.json"
    ];
    difftastic.enable = true;
  };
}
