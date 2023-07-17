{theme, ...}: let
  my-theme = with theme.xcolors; ''
    [Metadata]
    Name=my-theme
    Version=0.1
    Author=asa1984
    Description=My theme for fcitx5
    ScaleWithDPI=True

    [InputPanel]
    Font=Migu 1P 13
    NormalColor=${fg}
    HighlightCandidateColor=${blue}
    HighlightColor=#1a1b26
    HighlightBackgroundColor=${blue}
    Spacing=3

    [InputPanel/TextMargin]
    Left=10
    Right=10
    Top=6
    Bottom=6

    [InputPanel/Background]
    Color=${bg}

    [InputPanel/Background/Margin]
    Left=2
    Right=2
    Top=2
    Bottom=2

    [InputPanel/Highlight]
    Color=#2f334d

    [InputPanel/Highlight/Margin]
    Left=10
    Right=10
    Top=7
    Bottom=7

    [Menu/Background]
    Color=${bg}

    [Menu/Background/Margin]
    Left=2
    Right=2
    Top=2
    Bottom=2

    [Menu/ContentMargin]
    Left=2
    Right=2
    Top=2
    Bottom=2

    [Menu/Highlight]
    Color=#2f334d

    [Menu/Highlight/Margin]
    Left=10
    Right=10
    Top=5
    Bottom=5

    [Menu/Separator]
    Color=#2e3440

    [Menu/CheckBox]
    Image=radio.png

    [Menu/SubMenu]
    Image=arrow.png

    [Menu/TextMargin]
    Left=5
    Right=5
    Top=5
    Bottom=5
  '';
in {
  home.file = {
    ".local/share/fcitx5/themes/my-theme/theme.conf".text = my-theme;
    ".local/share/fcitx5/themes/my-theme/arrow.png".source = ./assets/arrow.png;
    ".local/share/fcitx5/themes/my-theme/panel.png".source = ./assets/panel.png;
    ".local/share/fcitx5/themes/my-theme/radio.png".source = ./assets/radio.png;
  };
}
