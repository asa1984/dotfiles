local wezterm = require("wezterm")

return {
	-- Theme
	color_scheme = "MyTheme",

	-- Font
	font = wezterm.font_with_fallback({
		{ family = "JetBrainsMono Nerd Font", weight = "Regular" },
		{ family = "JetBrainsMono Nerd Font", weight = "Regular", assume_emoji_presentation = true },
		{ family = "Noto Sans CJK JP" },
	}),
	-- font_size = 12.0,
	warn_about_missing_glyphs = false,
	window_frame = {
		font_size = 10.0,
	},

	-- Padding
	window_padding = {
		left = 10,
		right = 10,
		top = 5,
		bottom = 5,
	},

	-- Tab
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	-- Misc
	use_ime = true, -- Enable IME
	check_for_updates = false, -- Disable update check
	audible_bell = "Disabled", -- Disable bell
}
