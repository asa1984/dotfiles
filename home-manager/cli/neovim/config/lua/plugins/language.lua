-- Formatter & Linter
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
	sources = {
		-- C/C++
		null_ls.builtins.formatting.clang_format,
		-- JavaScript/TypeScript/Others
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
		-- Shell
		null_ls.builtins.diagnostics.shellcheck,
		null_ls.builtins.formatting.shfmt,
		-- Terraform
		null_ls.builtins.formatting.terraform_fmt,
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

-- Rust
local rust_tools = require("rust-tools")
rust_tools.setup({
	tools = { autoSetHints = true },
})
require("crates").setup() -- complete ctate versions
