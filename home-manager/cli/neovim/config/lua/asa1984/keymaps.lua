vim.g.mapleader = " "

-- Save file
vim.keymap.set("i", "<C-s>", "<Cmd>w<CR>")
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>")

-- Better escape
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- Better move
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Remove highlight
vim.keymap.set("n", "<Leader><Space>", "<Cmd>nohlsearch<CR>")

-- Terminal
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>") -- Escape from terminal by ESC
vim.keymap.set("n", "<leader>tt", "<Cmd>ToggleTerm<CR>")
vim.keymap.set("n", "<leader>th", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>")
vim.keymap.set("n", "<leader>gg", function()
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({
		cmd = "lazygit",
		direction = "float",
		float_opts = {
			border = "curved",
		},
	})
	lazygit:toggle()
end)

-- Smart splits
vim.keymap.set("n", "<C-h>", function()
	require("smart-splits").move_cursor_left()
end)
vim.keymap.set("n", "<C-j>", function()
	require("smart-splits").move_cursor_down()
end)
vim.keymap.set("n", "<C-k>", function()
	require("smart-splits").move_cursor_up()
end)
vim.keymap.set("n", "<C-l>", function()
	require("smart-splits").move_cursor_right()
end)
vim.keymap.set("n", "<C-Left>", function()
	require("smart-splits").resize_left()
end)
vim.keymap.set("n", "<C-Down>", function()
	require("smart-splits").resize_down()
end)
vim.keymap.set("n", "<C-Up>", function()
	require("smart-splits").resize_up()
end)
vim.keymap.set("n", "<C-Right>", function()
	require("smart-splits").resize_right()
end)

-- LSP
vim.keymap.set("n", "m", "<Plug>(lsp)")
vim.keymap.set("n", "K", require("lspsaga.hover").render_hover_doc)
vim.keymap.set("n", "<Plug>(lsp)d", vim.lsp.buf.definition)
vim.keymap.set("n", "<Plug>(lsp)a", require("lspsaga.codeaction").code_action)
vim.keymap.set("n", "<Plug>(lsp)rn", require("lspsaga.rename").rename)

-- Fold
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

-- Tab
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", ";q", "<Cmd>bd<CR>") -- Close Tab

-- File tree
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>")
vim.keymap.set("n", "<leader>o", function()
	if vim.bo.filetype == "neo-tree" then
		vim.cmd.wincmd("p")
	else
		vim.cmd.Neotree("focus")
	end
end)

-- Telescope
vim.keymap.set("n", ";f", function()
	require("telescope.builtin").find_files()
end)
vim.keymap.set("n", ";r", function()
	require("telescope.builtin").live_grep()
end)
