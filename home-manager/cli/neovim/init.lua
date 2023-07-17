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

-- Fold
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

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

-- Floating terminal
vim.keymap.set("n", "<Leader>tt", "<Cmd>FloatermToggle<CR>")

----------------
-- Treesitter --
----------------
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
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
-- Go
lspconfig.gopls.setup({})
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
		-- JavaScript/TypeScript/Others (Omit markdown)
		null_ls.builtins.formatting.prettier,
		-- Go
		null_ls.builtins.formatting.gofmt,
		-- Haskell
		null_ls.builtins.formatting.fourmolu,
		-- Lua
		null_ls.builtins.formatting.stylua,
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

-- Cmdline
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

-- Others
require("Comment").setup({})
require("nvim-autopairs").setup({
	map_c_h = true,
})
require("nvim-ts-autotag").setup({})

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
-- IDE --
---------
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

-- Highlight search result
require("hlslens").setup({
	calm_down = true,
})

-- Highlight color code
require("nvim-highlight-colors").setup({
	enable_tailwind = true,
})

-- Git
require("gitsigns").setup({})

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
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
require("ufo").setup({
	provider_selector = function(bufnr, filetype, buftype)
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
			local icon = level:match("error") and " " or " "
			return " " .. icon .. count
		end,
	},
})
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", ";q", "<Cmd>NvimTreeClose<bar>bd<CR>") -- Close Tab

-- Fuzzy finder
local telescope_actions = require("telescope.actions")
local telescope_builtin = require("telescope.builtin")
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			".git",
		},
		mappings = {
			n = {
				["q"] = telescope_actions.close,
			},
		},
	},
})
vim.keymap.set("n", ";f", function()
	telescope_builtin.find_files()
end)
vim.keymap.set("n", ";r", function()
	telescope_builtin.live_grep()
end)

-- File tree
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

-- Toggleterm
require("toggleterm").setup({
	size = 10,
	shading_factor = 2,
	open_mapping = [[<F7>]],
	direction = "float",
	float_opts = {
		border = "curved",
	},
})
local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
	cmd = "lazygit",
	direction = "float",
	float_opts = {
		border = "curved",
	},
})
vim.keymap.set("n", "<leader>gg", function()
	lazygit:toggle()
end)
vim.keymap.set("n", "<leader>tt", "<Cmd>ToggleTerm<CR>")
vim.keymap.set("n", "<leader>th", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>")

--------
-- UI --
--------
-- Nerd font icons
require("nvim-web-devicons").setup({})
