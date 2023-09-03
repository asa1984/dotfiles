return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = function()
		local telescope_actions = require("telescope.actions")
		return {
			defaults = {
				file_ignore_patterns = {
					"node_modules",
					".git",
				},
				mappings = {
					n = {
						["q"] = telescope_actions.close,
					},
				},
			},
		}
	end,
}
