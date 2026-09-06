{ hostname, inputs, ... }:
{
  imports = [
    inputs.comin.darwinModules.comin
  ];

  services.comin = {
    enable = true;
    # flake.nix の場所: https://github.com/asa1984/dotfiles の hosts/<hostname>/
    # ?dir= を付けても取得されるのはリポジトリ全体のため、
    # flake 内の ../../lib, ../../modules 等の親参照は解決できる。
    repositorySubdir = "hosts/${hostname}";
    remotes = [
      {
        name = "origin";
        url = "https://github.com/asa1984/dotfiles.git";
        branches.main.name = "main";
        poller.period = 300;
      }
    ];
  };
}
