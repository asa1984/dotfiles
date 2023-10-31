return {
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "BufRead",
		opts = function()
			local nls = require("null-ls")
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
			return {
				sources = {
					-- C/C++
					nls.builtins.formatting.clang_format,
					-- CUE
					nls.builtins.formatting.cue_fmt,
					-- Deno
					nls.builtins.formatting.deno_fmt.with({
						condition = function(utils)
							return not (utils.has_file({ ".prettierrc", ".prettierrc.js", "package.json" }))
						end,
					}),
					-- JavaScript/TypeScript/Others
					nls.builtins.formatting.prettier.with({
						prefer_local = "node_modules/.bin",
					}),
					nls.builtins.diagnostics.eslint.with({
						prefer_local = "node_modules/.bin",
						condition = function(utils)
							return utils.root_has_file("eslint.config.js")
								or utils.root_has_file("eslint.config.cjs")
								or utils.root_has_file("eslint.config.mjs")
								or utils.root_has_file(".eslintrc")
								or utils.root_has_file(".eslintrc.js")
								or utils.root_has_file(".eslintrc.cjs")
								or utils.root_has_file(".eslintrc.mjs")
								or utils.root_has_file(".eslintrc.json")
								or utils.root_has_file(".eslintrc.yml")
								or utils.root_has_file(".eslintrc.yaml")
						end,
					}),
					-- Go
					nls.builtins.formatting.gofmt,
					-- Haskell
					nls.builtins.formatting.fourmolu,
					-- Lua
					nls.builtins.formatting.stylua,
					-- Nix
					nls.builtins.formatting.alejandra,
					-- OCaml
					nls.builtins.formatting.ocamlformat,
					-- Python
					nls.builtins.formatting.black,
					-- Rust
					nls.builtins.formatting.rustfmt.with({
						extra_args = function(params)
							local Path = require("plenary.path")
							local cargo_toml = Path:new(params.root .. "/" .. "Cargo.toml")

							if cargo_toml:exists() and cargo_toml:is_file() then
								for _, line in ipairs(cargo_toml:readlines()) do
									local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
									if edition then
										return { "--edition=" .. edition }
									end
								end
							end
							-- default edition when we don't find `Cargo.toml` or the `edition` in it.
							return { "--edition=2021" }
						end,
					}),
					-- Shell
					nls.builtins.diagnostics.shellcheck,
					nls.builtins.formatting.shfmt,
					-- -- SQL
					-- nls.builtins.formatting.sql_formatter,
					-- Protocol Buffers
					nls.builtins.formatting.buf,
					-- Terraform
					nls.builtins.formatting.terraform_fmt,
					-- TOML
					nls.builtins.formatting.taplo,
					-- Zig
					nls.builtins.formatting.zigfmt,
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
			}
		end,
	},

	{
		"kaarmu/typst.vim",
		ft = "typst",
		lazy = false,
	},
}