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

-- Format of diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = {
		format = function(diagnostic)
			return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
})

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
