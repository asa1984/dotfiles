local wezterm = require("wezterm")

return {
	-- Theme
	color_scheme = "MyTheme",

	-- Font
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 14.0,

	-- Padding
	window_padding = {
		left = 10,
		right = 10,
		top = 10,
		bottom = 10,
	},

	-- Tab
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	-- Misc
	use_ime = true,
	check_for_updates = false,
}
