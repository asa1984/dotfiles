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
vim.keymap.set("n", "<leader>tf", "<Cmd>ToggleTerm direction=float<CR>")
vim.keymap.set("n", "<leader>th", "<Cmd>ToggleTerm direction=horizontal size=15<CR>")
vim.keymap.set("n", "<leader>tv", "<Cmd>ToggleTerm direction=vertical size=70<CR>")
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

-- Buffer
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>")
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>")
vim.keymap.set("n", ";q", function()
	local bufnr = vim.api.nvim_get_current_buf()
	require("mini.bufremove").delete(bufnr)
end)
vim.keymap.set("n", "<leader>bh", vim.cmd.split)
vim.keymap.set("n", "<leader>bv", vim.cmd.vsplit)

-- smart-splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
vim.keymap.set("n", "<C-Left>", require("smart-splits").resize_left)
vim.keymap.set("n", "<C-Down>", require("smart-splits").resize_down)
vim.keymap.set("n", "<C-Up>", require("smart-splits").resize_up)
vim.keymap.set("n", "<C-Right>", require("smart-splits").resize_right)
vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)

-- LSP
vim.keymap.set("n", "m", "<Plug>(lsp)")
vim.keymap.set("n", "K", require("lspsaga.hover").render_hover_doc)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<Plug>(lsp)a", require("lspsaga.codeaction").code_action)
vim.keymap.set("n", "<Plug>(lsp)rn", require("lspsaga.rename").rename)

-- Fold
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

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
