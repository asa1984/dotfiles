vim.g.mapleader = " "

-- Character code
vim.encoding = "utf-8"
vim.fileencoding = "utf-8"
vim.opt.encoding = "utf-8"

-- Scroll
vim.opt.scrolloff = 8

-- Row
vim.opt.number = true
vim.opt.numberwidth = 5
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
vim.opt.foldcolumn = "1"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- UI
vim.opt.cmdheight = 1
vim.opt.laststatus = 3 -- Always show statusline
vim.opt.showtabline = 2 -- Always show tabline
vim.opt.termguicolors = true -- Enable 24-bit RGB colors

-- File
vim.opt.backup = false
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.updatetime = 500

-- Misc
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.mouse = "" -- Disable mouse

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
