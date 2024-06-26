{ pkgs, pkgs-stable, ... }:
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
  programs.git = {
    enable = true;
    userName = "asa1984";
    userEmail = "satoasa9913@gmail.com";

    delta.enable = true;

    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    package = pkgs-stable.gh;
    extensions = [
      pkgs.gh-markdown-preview
      gh-q
    ];
  };
}
