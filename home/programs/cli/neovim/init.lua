-----------------
-- Vim Options --
-----------------
vim.opt.number = true
vim.opt.cmdheight = 1
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.breakindent = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hidden = true
vim.opt.backup = false

------------
-- Keymap --
------------
vim.g.mapleader = " "
vim.keymap.set("i", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-b>", "<Cmd>NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>f", "<Cmd>Telescope find_files<CR>")

---------
-- LSP --
---------
local lspconfig = require("lspconfig")
-- JavaScript/TypeScript
lspconfig.tsserver.setup({})

-- Lua
lspconfig.sumneko_lua.setup({
	cmd = { "lua-language-server" },
	settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- Nix
lspconfig.nil_ls.setup({})

-- Rust
local rust_tools = require("rust-tools")
rust_tools.setup({
	tools = { autoSetHints = true },
})
require("crates").setup({})

-- LSP: Signature
require("lsp_signature").setup()

-- LSP: UI
require("fidget").setup({})

------------------------
-- Formatter & Linter --
------------------------
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
	sources = {
		-- Lua
		null_ls.builtins.formatting.stylua,
		-- Markdown
		null_ls.builtins.diagnostics.markdownlint,
		null_ls.builtins.formatting.markdownlint,
		-- Nix
		null_ls.builtins.code_actions.statix,
		null_ls.builtins.diagnostics.deadnix,
		null_ls.builtins.formatting.alejandra,
		-- Rust
		null_ls.builtins.formatting.rustfmt,
	},

	-- Format on save
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						bufnr = bufnr,
						filter = function(fmt_client)
							return fmt_client.name == "null-ls"
						end,
					})
				end,
			})
		end
	end,
})

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
		completion = cmp.config.window.bordered(),
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

---------
-- IDE --
---------
require("nvim-autopairs").setup({
	map_c_h = true,
})
require("nvim_comment").setup({
	line_mapping = "<C-_>",
})
require("colorizer").setup({})

-- Indent
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
require("indent_blankline").setup({
	show_end_of_line = true,
})

----------------
-- Navigation --
----------------
require("which-key").setup({})
require("nvim-tree").setup()
require("hlslens").setup()

--------
-- UI --
--------
require("mini.starter").setup({})
require("lualine").setup({
	options = {
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "" },
		lualine_y = { "filetype" },
		lualine_z = { "location" },
	},
})
require("nvim-web-devicons").setup({})
