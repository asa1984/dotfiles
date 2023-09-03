return {
	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		opts = {
			size = 10,
			shading_factor = 2,
			open_mapping = [[<f7>]],
			direction = "float",
			float_opts = {
				border = "curved",
			},
		},
	},

	-- Indent
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		opts = {
			show_end_of_line = true,
			show_trailing_blankline_indent = false,
			use_treesitter = true,
			buftype_exclude = {
				"nofile",
				"terminal",
			},
			filetype_exclude = {
				"help",
				"startify",
				"aerial",
				"alpha",
				"dashboard",
				"lazy",
				"neogitstatus",
				"NvimTree",
				"neo-tree",
				"Trouble",
			},
			context_patterns = {
				"class",
				"return",
				"function",
				"method",
				"^if",
				"^while",
				"jsx_element",
				"^for",
				"^object",
				"^table",
				"block",
				"arguments",
				"if_statement",
				"else_clause",
				"jsx_element",
				"jsx_self_closing_element",
				"try_statement",
				"catch_clause",
				"import_statement",
				"operation_type",
			},
		},
	},

	-- Fold
	{
		"kevinhwang91/nvim-ufo",
		event = "BufReadPost",
		dependencies = {
			"kevinhwang91/promise-async",
			{
				"luukvbaal/statuscol.nvim",
				config = function()
					local builtin = require("statuscol.builtin")
					require("statuscol").setup({
						relculright = true,
						segments = {
							{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
							{ text = { "%s" }, click = "v:lua.ScSa" },
							{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
						},
					})
				end,
			},
		},
		opts = {
			provider_selector = function()
				return { "treesitter", "indent" }
			end,
		},
	},

	-- Scrollbar
	{
		"petertriho/nvim-scrollbar",
		event = "BufReadPost",
		dependencies = "kevinhwang91/nvim-hlslens",
		config = function()
			local colors = require("tokyonight.colors").setup()
			require("scrollbar").setup({
				hide_if_all_visible = true,
				excluded_buftypes = {
					"TelescopePrompt",
					"neo-tree",
					"noice",
					"notify",
					"prompt",
					"terminal",
				},
				handle = { color = colors.bg_highlight },
				marks = {
					Search = { color = colors.orange },
					Error = { color = colors.error },
					Warn = { color = colors.warning },
					Info = { color = colors.info },
					Hint = { color = colors.hint },
					Misc = { color = colors.purple },
				},
			})

			-- Search highlight
			require("scrollbar.handlers.search").setup({ -- wrapper for hlslens.nvim
				calm_down = true,
			})
		end,
	},

	-- gitsigns
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufRead", "BufNewFile" },
		opts = {},
	},
}
