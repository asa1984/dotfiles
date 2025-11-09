{
  programs.git = {
    enable = true;
    signing = {
      key = "D6B5DF95C5360AE9";
      signByDefault = false;
    };
    settings = {
      user = {
        email = "satoasa9913@gmail.com";
        name = "asa1984";
      };

      init.defaultBranch = "main";

      commit.gpgsign = false;
      fetch = {
        prune = true;
        pruneTags = true;
      };
      merge.conflictStyle = "zdiff3";
      pull = {
        autoStash = true;
        rebase = true;
      };
      push.autoSetupRemote = true;
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
    };
    ignores = [
      ".DS_Store"
      ".claude/settings.local.json"
      ".devenv"
      ".direnv"
      ".neoconf.json"
    ];
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
