-- Fuzzy finder
local telescope_actions = require("telescope.actions")
require("telescope").setup({
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
})
