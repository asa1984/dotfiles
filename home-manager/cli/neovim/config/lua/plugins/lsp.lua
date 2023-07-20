local lspconfig = require("lspconfig")
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

-- Better LSP UI
require("lspsaga").init_lsp_saga({
	border_style = "round",
})
