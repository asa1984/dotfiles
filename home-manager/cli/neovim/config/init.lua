vim.loader.enable() -- You need to enable vim.loader before loading plugins

-- Color scheme
vim.cmd("colorscheme tokyonight-moon")

require("asa1984/options")
require("asa1984/keymaps")

-- LSP for Neovim config
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({})

require("plugins/lsp")
require("plugins/language")
require("plugins/cmp")
require("plugins/syntax")
require("plugins/filer")
require("plugins/finder")
require("plugins/ui")
