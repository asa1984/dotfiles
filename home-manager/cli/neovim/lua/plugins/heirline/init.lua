return {
	-- Statusline & Tabline
	{
		"rebelot/heirline.nvim",
		event = "BufEnter",
		opts = function()
			return {
				statusline = require("plugins.heirline.statusline"),
				tabline = require("plugins.heirline.tabline"),
				opts = {
					colors = require("tokyonight.colors").setup({
						style = "moon",
					}),
				},
			}
		end,
	},
}
