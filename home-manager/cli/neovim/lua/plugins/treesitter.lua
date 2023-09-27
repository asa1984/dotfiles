return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
				},
				ensure_installed = {
					"astro",
					"bash",
					"c",
					"comment",
					"cpp",
					"css",
					"cue",
					"dockerfile",
					"go",
					"gomod",
					"graphql",
					"haskell",
					"html",
					"javascript",
					"jsdoc",
					"json",
					"jsonc",
					"lua",
					"make",
					"markdown",
					"markdown_inline", -- Lspsaga require this
					"nix",
					"ocaml",
					"prisma",
					"python",
					"regex",
					"rust",
					"scss",
					"sql",
					"terraform",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"yaml",
					"zig",
				},
			})
		end,
	},

	-- Highlight inline code of home-manager config
	{ "calops/hmts.nvim", event = "BufRead", version = "*" },
}
