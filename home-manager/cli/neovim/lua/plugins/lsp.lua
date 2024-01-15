local get_icon = require("utils").get_icon

return {
	-- LSP for Neovim config
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "folke/neodev.nvim", opts = {} },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- Bash
			lspconfig.bashls.setup({})
			-- C/C++
			local clang_capabilities = vim.lsp.protocol.make_client_capabilities() -- null-ls.nvim issue#428
			clang_capabilities.offsetEncoding = { "utf-16" }
			lspconfig.clangd.setup({
				capabilities = clang_capabilities,
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			})
			-- CSS
			lspconfig.cssls.setup({ capabilities = capabilities })
			-- CUE
			lspconfig.dagger.setup({})
			-- Deno
			lspconfig.denols.setup({
				root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
				single_file = true,
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
			-- GraphQL
			lspconfig.graphql.setup({})
			-- Haskell
			lspconfig.hls.setup({})
			-- HTML
			lspconfig.html.setup({ capabilities = capabilities })
			-- JavaScript/TypeScript
			lspconfig.tsserver.setup({
				root_dir = lspconfig.util.root_pattern("package.json"),
				single_file_support = false,
			})
			lspconfig.biome.setup({})
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
			-- OCaml
			lspconfig.ocamllsp.setup({})
			-- Prisma
			lspconfig.prismals.setup({})
			-- Protocol Buffers
			lspconfig.bufls.setup({})
			-- Python
			lspconfig.pyright.setup({})
			-- Svelte
			lspconfig.svelte.setup({})
			-- TailwindCSS
			lspconfig.tailwindcss.setup({})
			-- Terraform
			lspconfig.terraformls.setup({})
			-- Typst
			lspconfig.typst_lsp.setup({})
			-- Zig
			lspconfig.zls.setup({})

			-- Format of diagnostics
			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
					virtual_text = {
						format = function(diagnostic)
							return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
						end,
					},
				})
		end,
	},

	-- Rust
	{
		"simrat39/rust-tools.nvim",
		event = "BufRead",
		opts = {
			tools = { autoSetHints = true },
		},
	},

	-- Managing crates.io dependencies
	{
		"saecki/crates.nvim",
		event = "BufRead Cargo.toml",
		config = function()
			require("crates").setup()
		end,
	},

	-- Better UI
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- optional
			"nvim-tree/nvim-web-devicons", -- optional
		},
		opts = function()
			return {
				ui = {
					border = "rounded",
					code_action = get_icon("DiagnosticHint"),
				},
				lightbulb = {
					sign = false,
				},
			}
		end,
	},
}
