local get_icon = require("asa1984/icons").get_icon

-- File tree
require("neo-tree").setup({
	close_if_last_window = true,
	window = {
		width = 30,
		mappings = {
			["<space>"] = false,
		},
	},
	default_component_configs = {
		indent = { padding = 0 },
		icon = {
			folder_closed = get_icon("FolderClosed"),
			folder_open = get_icon("FolderOpen"),
			folder_empty = get_icon("FolderEmpty"),
			folder_empty_open = get_icon("FolderEmpty"),
			default = get_icon("DefaultFile"),
		},
		modified = { symbol = get_icon("FileModified") },
		git_status = {
			symbols = {
				added = get_icon("GitAdd"),
				deleted = get_icon("GitDelete"),
				modified = get_icon("GitChange"),
				renamed = get_icon("GitRenamed"),
				untracked = get_icon("GitUntracked"),
				ignored = get_icon("GitIgnored"),
				unstaged = get_icon("GitUnstaged"),
				staged = get_icon("GitStaged"),
				conflict = get_icon("GitConflict"),
			},
		},
	},
})
