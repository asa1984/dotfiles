vim.loader.enable() -- You need to enable vim.loader before loading plugins

-- Color scheme
vim.cmd("colorscheme tokyonight-moon")

require("asa1984/options")
require("asa1984/keymaps")

require("asa1984/language")
require("asa1984/cmp")
require("asa1984/ide")
require("asa1984/ui")
