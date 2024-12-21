local wezterm = require("wezterm")

return {
	-- Theme
	color_scheme = "MyTheme",

	-- Font
	font = wezterm.font_with_fallback({
		{ family = "HackGen Console NF", weight = "Regular" },
		{ family = "HackGen Console NF", weight = "Regular", assume_emoji_presentation = true },
		"Noto Color Emoji",
	}),
	font_size = 16.0,
	window_frame = {
		font_size = 14.0,
	},
	warn_about_missing_glyphs = false,

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

	-- IME
	use_ime = true, -- Enable IME
	macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",

	-- Misc
	check_for_updates = false, -- Disable update check
	audible_bell = "Disabled", -- Disable bell
	front_end = "WebGpu", -- macOS requires this
}
