-----------------
-- Performance --
-----------------
vim.loader.enable() -- You need to enable loader before loading plugins

------------------
-- Color scheme --
------------------
vim.cmd("colorscheme tokyonight-moon")

-----------------
-- Vim Options --
-----------------
-- Character code
vim.opt.encoding = "utf-8"
vim.encoding = "utf-8"
vim.fileencoding = "utf-8"

-- Row
vim.opt.number = true
vim.opt.cursorline = true

-- Tab, Indent
vim.opt.tabstop = 2
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.autoindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Backup, Swapfile
vim.opt.backup = false
vim.opt.swapfile = false

-- Misc
vim.opt.termguicolors = true
vim.opt.cmdheight = 1
vim.opt.hidden = true
vim.opt.updatetime = 1000
vim.opt.mouse = "" -- Disable mouse
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

------------
-- Keymap --
------------
vim.g.mapleader = " "
vim.keymap.set("i", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- Move column
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Remove highlight
vim.keymap.set("n", "<Leader><Space>", "<Cmd>nohlsearch<CR>")

-- Escape from terminal mode
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>")

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

---------
-- LSP --
---------
-- Format of diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = {
		format = function(diagnostic)
			return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})

-- LSP config
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
-- C/C++
lspconfig.clangd.setup({})
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
-- Haskell
lspconfig.hls.setup({})
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
-- Prisma
lspconfig.prismals.setup({})
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

-- Holding cursor, show diagnostics
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
		-- C/C++
		null_ls.builtins.formatting.clang_format,
		-- -- Deno
		-- null_ls.builtins.formatting.deno_fmt.with({
		-- 	filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
		-- }),
		-- JavaScript/TypeScript/Others
		null_ls.builtins.formatting.prettier,
		-- Haskell
		null_ls.builtins.formatting.fourmolu,
		-- Lua
		null_ls.builtins.formatting.stylua,
		-- Markdown
		null_ls.builtins.diagnostics.markdownlint,
		-- Nix
		null_ls.builtins.code_actions.statix,
		null_ls.builtins.diagnostics.deadnix,
		null_ls.builtins.formatting.alejandra,
		-- Python
		null_ls.builtins.formatting.black,
		-- Rust
		null_ls.builtins.formatting.rustfmt,
		-- TOML
		null_ls.builtins.formatting.taplo,
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
require("nvim-highlight-colors").setup({
	enable_tailwind = true,
})
require("nvim-ts-autotag").setup({})
require("gitsigns").setup({})

-- Indent
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
require("indent_blankline").setup({
	show_end_of_line = true,
})

-- Tab
require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		always_show_bufferline = false,
		show_close_icon = false,
		show_buffer_close_icons = false,
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and " " or " "
			return " " .. icon .. count
		end,
	},
})
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", ";q", "<Cmd>NvimTreeClose<bar>bd<CR>") -- Close Tab

----------------
-- Navigation --
----------------
-- Highlight search result
require("hlslens").setup()

-- Which-Key
vim.opt.timeout = true
vim.opt.timeoutlen = 500
require("which-key").setup()

-- Telescope
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			".git",
		},
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

-- Nvim-tree
require("nvim-tree").setup({
	git = {
		enable = true,
		ignore = false,
	},
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
-- Nerd font icons
require("nvim-web-devicons").setup({})

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
				symbols = { error = " ", warn = " ", info = " ", hing = " " },
			},
		},
		lualine_y = { "filetype" },
		lualine_z = { "location" },
	},
})
