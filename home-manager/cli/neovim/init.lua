vim.loader.enable() -- You need to enable vim.loader before loading plugins

require("config.options")

require("lazy").setup({
	defaults = { lazy = true },
	spec = {
		import = "plugins",
	},
	install = {
		colorscheme = { "tokyonight" },
	},
})

require("config.keymaps")
