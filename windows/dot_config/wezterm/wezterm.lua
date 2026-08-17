-- Windows 向け WezTerm 設定 (chezmoi 管理)
-- configs/home-manager/wezterm/wezterm.lua がベース
local wezterm = require("wezterm")

return {
    -- Shell
    default_prog = { "nu" },

    -- Theme
    color_scheme = "MyTheme",

    -- Font
    font = wezterm.font_with_fallback({
        { family = "HackGen Console NF", weight = "Regular" },
        { family = "HackGen Console NF", weight = "Regular", assume_emoji_presentation = true },
        "Segoe UI Emoji",
    }),
    font_size = 12.0, -- mac (16pt) と DPI の扱いが違うため小さめ
    window_frame = {
        font_size = 11.0,
    },
    warn_about_missing_glyphs = false,

    -- Padding
    window_padding = {
        left = 10,
        right = 10,
        top = 5,
        bottom = 5,
    },

    -- Window (通常の Windows タイトルバーを表示する)
    window_decorations = "TITLE | RESIZE",

    -- Tab
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,

    -- IME (日本語入力に必須)
    use_ime = true,

    -- Misc
    check_for_updates = false,
    audible_bell = "Disabled",
    front_end = "WebGpu",
}
