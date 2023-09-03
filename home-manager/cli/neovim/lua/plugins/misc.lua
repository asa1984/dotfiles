return {
	"folke/twilight.nvim",

	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			plugins = {
				gitsigns = true,
			},
		},
	},

	-- Highlight color codes
	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufRead",
		opts = { enable_tailwind = true },
	},
}
