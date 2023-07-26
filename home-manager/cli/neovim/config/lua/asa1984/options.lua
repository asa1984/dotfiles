-- Character code
vim.encoding = "utf-8"
vim.fileencoding = "utf-8"
vim.opt.encoding = "utf-8"

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

-- UI
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.cmdheight = 1
vim.opt.laststatus = 3 -- Always show statusline
vim.opt.showtabline = 2 -- Always show tabline

-- Misc
vim.opt.hidden = true
vim.opt.updatetime = 1000
vim.opt.mouse = "" -- Disable mouse
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
