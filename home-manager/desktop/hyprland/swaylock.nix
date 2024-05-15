{ pkgs, theme, ... }:
{
  home.packages = [ pkgs.swaylock-effects ];
  home.file.".config/swaylock/config".text = with theme.colors; ''
    ignore-empty-password

    font=Noto Sans CJK JP
    font-size=50
    indicator-idle-visible
    indicator-thickness=15
    indicator-radius=150

    inside-color=00000000
    inside-clear-color=00000000
    inside-ver-color=00000000
    inside-wrong-color=00000000
    key-hl-color=${white}
    bs-hl-color=${cyan}

    layout-bg-color=00000000
    layout-border-color=00000000
    layout-text-color=${fg}

    line-color=00000000
    line-clear-color=00000000
    line-ver-color=00000000
    line-wrong-color=00000000

    ring-color=${fg}
    ring-clear-color=${cyan}
    ring-ver-color=${white}
    ring-wrong-color=${red}

    separator-color=00000000
    text-color=${fg}
    text-clear-color=${cyan}
    text-ver-color=${fg}
    text-wrong-color=${red}

    effect-blur=5x5
    clock
    timestr=%H:%M:%S
    datestr=%a, %b %d
  '';
}
