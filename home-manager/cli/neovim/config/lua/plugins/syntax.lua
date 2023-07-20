-- Syntax
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
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

-- Color code
require("nvim-highlight-colors").setup({
	enable_tailwind = true,
})
