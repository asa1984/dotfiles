{ pkgs, ... }:
# Replace macOS's BSD-flavored CLI tools with their GNU counterparts so the
# command-line behaves like Linux (flags, semantics, output). These install
# unprefixed binaries (ls, sed, awk, ...) into the home-manager profile, which
# sits ahead of /usr/bin on PATH and therefore shadows the BSD versions.
# macOS-only; NixOS already ships the GNU userland.
{
  home.packages = with pkgs; [
    coreutils # ls, cat, cp, mv, rm, date, du, df, head, tail, sort, stat, realpath, timeout, ...
    diffutils # diff, cmp, diff3
    findutils # find, xargs, locate
    gawk # awk
    gnugrep # grep, egrep, fgrep
    gnumake # make
    gnupatch # patch
    gnused # sed
    gnutar # tar
    gzip # gzip, gunzip, zcat
    less # newer GNU-compatible less
  ];
}
