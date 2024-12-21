{ pkgs, ... }:
let
  # gh-q and gh-fuzzyclone are not available on nixpkgs
  # Their shebangs are "#!/bin/bash" which is not available on NixOS
  # Replace original shebang with "#!/usr/bin/env sh" for NixOS
  gh-q = pkgs.stdenv.mkDerivation rec {
    name = "gh-q";
    pname = name;
    src = pkgs.fetchFromGitHub {
      owner = "kawarimidoll";
      repo = "gh-q";
      rev = "5dc627f350902e0166016a9dd1f9479c75e3f392";
      hash = "sha256-A0xYze0LCA67Qmck3WXiUihchLyjbOzWNQ++mitf3bk=";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      sed 1d $src/gh-q > $out/bin/gh-q # remove original shebang
      sed -i "1i#!\/usr\/bin\/env sh" $out/bin/gh-q # add new shebang
      chmod +x $out/bin/gh-q # make executable
    '';
  };
in
{
  programs.gpg.enable = true;

  programs.git = {
    enable = true;
    userName = "asa1984";
    userEmail = "satoasa9913@gmail.com";
    signing = {
      key = "D6B5DF95C5360AE9";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      commit.gpgsign = true;
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

  programs.gh = {
    enable = true;
    extensions = [
      pkgs.gh-dash
      pkgs.gh-markdown-preview
      gh-q
    ];
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          externalDiffCommand = "${pkgs.difftastic}/bin/difft --color=always";
        };
      };
    };
  };
}
