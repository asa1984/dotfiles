local get_icon = require("asa1984/icons").get_icon

-- Startup page
require("alpha").setup(require("alpha.themes.startify").config)

-- Statusline
require("lualine").setup({
	options = {
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = {
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = {
					error = get_icon("DiagnosticError") .. " ",
					warn = get_icon("DiagnosticWarn") .. " ",
					info = get_icon("DiagnosticInfo") .. " ",
					hint = get_icon("DiagnosticHint") .. " ",
				},
			},
		},
		lualine_y = { "filetype" },
		lualine_z = { "location" },
	},
})

-- File tree
require("neo-tree").setup({
	close_if_last_window = true,
	window = {
		width = 30,
		mappings = {
			["<space>"] = false,
		},
	},
	default_component_configs = {
		indent = { padding = 0 },
		icon = {
			folder_closed = get_icon("FolderClosed"),
			folder_open = get_icon("FolderOpen"),
			folder_empty = get_icon("FolderEmpty"),
			folder_empty_open = get_icon("FolderEmpty"),
			default = get_icon("DefaultFile"),
		},
		modified = { symbol = get_icon("FileModified") },
		git_status = {
			symbols = {
				added = get_icon("GitAdd"),
				deleted = get_icon("GitDelete"),
				modified = get_icon("GitChange"),
				renamed = get_icon("GitRenamed"),
				untracked = get_icon("GitUntracked"),
				ignored = get_icon("GitIgnored"),
				unstaged = get_icon("GitUnstaged"),
				staged = get_icon("GitStaged"),
				conflict = get_icon("GitConflict"),
			},
		},
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
		inc_rename = true, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
})

-- Indent
require("indent_blankline").setup({
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
})

-- Fold
require("ufo").setup({
	provider_selector = function()
		return { "treesitter", "indent" }
	end,
})
local statuscol_builtin = require("statuscol.builtin")
require("statuscol").setup({
	relculright = true,
	segments = {
		{ text = { statuscol_builtin.foldfunc }, click = "v:lua.ScFa" },
		{ text = { "%s" }, click = "v:lua.ScSa" },
		{ text = { statuscol_builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
	},
})

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

-- Scrollbar
require("scrollbar").setup({
	excluded_buftypes = {
		"terminal",
		"neo-tree",
	},
})
require("scrollbar.handlers.gitsigns").setup()

-- Search highlight
require("scrollbar.handlers.search").setup({ -- wrapper for nvim-scrollbar
	-- hlslens config overrides
	calm_down = true,
})

-- Color code
require("nvim-highlight-colors").setup({
	enable_tailwind = true,
})

-- Git
require("gitsigns").setup({})

-- Nerd font icons
require("nvim-web-devicons").setup({})
