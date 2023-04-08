-----------------
-- Performance --
-----------------
require("impatient")

--------------------
-- GitHub Copilot --
--------------------
require("copilot").setup({
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
})

-----------------
-- Vim Options --
-----------------
vim.opt.number = true
vim.opt.termguicolors = true
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
vim.opt.updatetime = 1000

------------
-- Keymap --
------------
vim.g.mapleader = " "
vim.keymap.set("i", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

---------
-- LSP --
---------
local lspconfig = require("lspconfig")

require("lspsaga").init_lsp_saga({
	border_style = "round",
})
require("lsp_signature").setup()
require("fidget").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Bash
lspconfig.bashls.setup({})
-- CSS
lspconfig.cssls.setup({ capabilities = capabilities })
-- Deno
lspconfig.denols.setup({
	root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
	init_options = {
		lint = true,
		unstable = true,
		suggest = {
			imports = {
				hosts = {
					["https://deno.land"] = true,
					["https://cdn.nest.land"] = true,
					["https://crux.land"] = true,
				},
			},
		},
	},
})
vim.g.markdown_fenced_languages = { "ts=typescript" }
-- Docker
lspconfig.dockerls.setup({})
-- HTML
lspconfig.html.setup({ capabilities = capabilities })
-- JavaScript/TypeScript
lspconfig.tsserver.setup({
	root_dir = lspconfig.util.root_pattern("package.json"),
	single_file_support = false,
})
-- JSON
lspconfig.jsonls.setup({ capabilities = capabilities })
-- Lua
lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})
-- Nix
lspconfig.nil_ls.setup({})
-- Python
lspconfig.pyright.setup({})
-- Rust
local rust_tools = require("rust-tools")
rust_tools.setup({
	tools = { autoSetHints = true },
})
-- Rust: complete ctate versions
require("crates").setup()
-- Svelte
lspconfig.svelte.setup({})
-- TailwindCSS
lspconfig.tailwindcss.setup({})
-- Zig
lspconfig.zls.setup({})

-- holding cursor, show diagnostics
vim.api.nvim_create_autocmd({ "CursorHold" }, {
	pattern = { "*" },
	callback = function()
		require("lspsaga.diagnostic").show_cursor_diagnostics()
	end,
})

vim.keymap.set("n", "m", "<Plug>(lsp)")
vim.keymap.set("n", "K", require("lspsaga.hover").render_hover_doc)
vim.keymap.set("n", "<Plug>(lsp)d", vim.lsp.buf.definition)
vim.keymap.set("n", "<Plug>(lsp)a", require("lspsaga.codeaction").code_action)
vim.keymap.set("n", "<Plug>(lsp)rn", require("lspsaga.rename").rename)

------------------------
-- Formatter & Linter --
------------------------
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
	sources = {
		-- Deno
		null_ls.builtins.formatting.deno_fmt.with({
			filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
		}),
		-- Lua
		null_ls.builtins.formatting.stylua,
		-- Markdown
		null_ls.builtins.diagnostics.markdownlint,
		null_ls.builtins.formatting.markdownlint,
		-- Nix
		null_ls.builtins.code_actions.statix,
		null_ls.builtins.diagnostics.deadnix,
		null_ls.builtins.formatting.alejandra,
		-- Python
		null_ls.builtins.formatting.black,
		-- Rust
		null_ls.builtins.formatting.rustfmt,
		-- Zig
		null_ls.builtins.formatting.zigfmt,
	},

	-- disable netrw
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
})

----------------
-- Completion --
----------------
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	formatting = {
		format = lspkind.cmp_format({
			mode = "text",
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
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
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
require("nvim-ts-autotag").setup({})
require("colorizer").setup({})
require("gitsigns").setup({})

-- indent
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
require("indent_blankline").setup({
	show_end_of_line = true,
})

-- tab
require("bufferline").setup({})
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", ";q", ":bprevious<CR> :bdelete #<CR>") -- delete tab

-- hover info
-- vim.keymap.set("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>")
-- vim.keymap.set("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
-- 	border = "rounded",
-- })
-- vim.cmd("highlight! link FloatBorder NormalFloat")
--
-- Navigation --
----------------
-- highlight search result
require("hlslens").setup()

-- which-key
vim.opt.timeout = true
vim.opt.timeoutlen = 500
require("which-key").setup()

-- telescope
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
require("telescope").setup({
	defaults = {
		mappings = {
			n = {
				["q"] = actions.close,
			},
		},
	},
})
vim.keymap.set("n", ";f", function()
	builtin.find_files()
end)
vim.keymap.set("n", ";r", function()
	builtin.live_grep()
end)

-- nvim-tree
require("nvim-tree").setup({
	view = {
		width = 25,
	},
})
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.keymap.set("n", "<C-b>", "<Cmd>NvimTreeToggle<CR>")
vim.keymap.set("n", ";b", "<Cmd>NvimTreeFocus<CR>")

--------
-- UI --
--------
-- nerd font icons
require("nvim-web-devicons").setup({})

-- startup page
require("alpha").setup(require("alpha.themes.startify").config)

-- statusline
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
