return {
	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme tokyonight-moon]])
		end,
	},

	-- Docs (ja)
	{
		"vim-jp/vimdoc-ja",
		ft = "help",
	},

	-- GitHub copilot
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		opts = {
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<C-j>",
					accept_word = false,
					accept_line = false,
					next = "<M-o>",
					prev = "<M-i>",
					dismiss = "<C-S-e>",
				},
			},
		},
	},

	-- Better escape
	{ "max397574/better-escape.nvim", event = "InsertCharPre" },

	-- Better pane navigation
	{
		"mrjones2014/smart-splits.nvim",
		opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
	},

	-- Better buffer remove
	{ "echasnovski/mini.bufremove" },

	{ "numToStr/Comment.nvim", event = "InsertEnter", opts = {} },

	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

	{ "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },
}
