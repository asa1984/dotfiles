local get_icon = require("asa1984/icons").get_icon

-- Tab
require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		always_show_bufferline = false,
		show_close_icon = false,
		show_buffer_close_icons = false,
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and get_icon("DiagnosticError") or get_icon("DiagnosticWarn")
			return " " .. icon .. " " .. count
		end,
	},
})

-- Terminal
require("toggleterm").setup({
	size = 10,
	shading_factor = 2,
	open_mapping = [[<f7>]],
	direction = "float",
	float_opts = {
		border = "curved",
	},
})

-- Scrollbar
require("scrollbar").setup({
	hide_if_all_visible = true,
	excluded_buftypes = {
		"terminal",
		"neo-tree",
	},
})
require("scrollbar.handlers.gitsigns").setup()

-- Git
require("gitsigns").setup({})

-- Search highlight
require("scrollbar.handlers.search").setup({ -- wrapper for nvim-scrollbar
	-- hlslens config overrides
	calm_down = true,
})

-- Noice
require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				kind = "search_count",
			},
			opts = { skip = true },
		},
	},
	cmdline = {
		view = "cmdline",
	},
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
})
