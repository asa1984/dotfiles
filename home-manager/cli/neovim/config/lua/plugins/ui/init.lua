require("plugins.ui.noice")
require("plugins.ui.startup")

local get_icon = require("asa1984.icons")

-- Statusline
require("heirline").setup({
	statusline = require("plugins.ui.statusline"),
	tabline = require("plugins.ui.tabline"),
	opts = {
		colors = require("tokyonight.colors").setup({
			style = "moon",
		}),
	},
})

-- Tab
-- require("bufferline").setup({
-- 	options = {
-- 		diagnostics = "nvim_lsp",
-- 		always_show_bufferline = false,
-- 		show_close_icon = false,
-- 		show_buffer_close_icons = false,
-- 		diagnostics_indicator = function(count, level)
-- 			local icon = level:match("error") and get_icon("DiagnosticError") or get_icon("DiagnosticWarn")
-- 			return " " .. icon .. " " .. count
-- 		end,
-- 	},
-- })

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
