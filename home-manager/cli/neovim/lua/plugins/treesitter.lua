return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		config = function()
			vim.opt.runtimepath:append("@treesitter_parsers@")
		end,
	},

	-- Highlight inline code of home-manager config
	{ "calops/hmts.nvim", event = "BufRead", version = "*" },
}
