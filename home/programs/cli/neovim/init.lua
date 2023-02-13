-----------------
-- Vim Options --
-----------------
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.hidden = true

---------
-- LSP --
---------
local lspconfig = require("lspconfig")
lspconfig.tsserver.setup({})
lspconfig.sumneko_lua.setup({})
lspconfig.nil_ls.setup({})

----------------
-- Treesitter --
----------------
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
})

----------------
-- Completion --
----------------
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol",
			maxwidth = 50,
		}),
	},
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	window = {
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<C-l>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "vsnip" },
		{ name = "path" },
	},
})

-- cmdline
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
		{ name = "cmdline" },
	}),
})

----------
-- Misc --
----------
require("nvim-autopairs").setup({})
