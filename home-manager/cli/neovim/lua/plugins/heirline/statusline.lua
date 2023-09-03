local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local get_icon = require("utils").get_icon

local ViMode = {
	init = function(self)
		self.mode = vim.fn.mode(1) -- :h mode()
	end,
	static = {
		mode_names = {
			n = "N",
			no = "N?",
			nov = "N?",
			noV = "N?",
			["no\22"] = "N?",
			niI = "Ni",
			niR = "Nr",
			niV = "Nv",
			nt = "Nt",
			v = "V",
			vs = "Vs",
			V = "V_",
			Vs = "Vs",
			["\22"] = "^V",
			["\22s"] = "^V",
			s = "S",
			S = "S_",
			["\19"] = "^S",
			i = "I",
			ic = "Ic",
			ix = "Ix",
			R = "R",
			Rc = "Rc",
			Rx = "Rx",
			Rv = "Rv",
			Rvc = "Rv",
			Rvx = "Rv",
			c = "C",
			cv = "Ex",
			r = "...",
			rm = "M",
			["r?"] = "?",
			["!"] = "!",
			t = "T",
		},
		mode_colors = {
			n = "blue",
			i = "green",
			v = "magenta",
			V = "magenta",
			["\22"] = "magenta",
			c = "yellow",
			s = "purple",
			S = "purple",
			["\19"] = "purple",
			R = "red",
			r = "red",
			["!"] = "green1",
			t = "green1",
		},
	},
	provider = function(self)
		return " " .. self.mode_names[self.mode] .. " "
	end,
	hl = function(self)
		local mode = self.mode:sub(1, 1) -- get only the first mode character
		return { fg = "bg", bg = self.mode_colors[mode] }
	end,
	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			vim.cmd("redrawstatus")
		end),
	},
}

local GitContext = {
	condition = conditions.is_git_repo,
	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
		self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
	end,
	{ -- git branch name
		provider = function(self)
			return "  " .. get_icon("GitBranch") .. " " .. self.status_dict.head .. "  "
		end,
		hl = { fg = "magenta", bold = true },
	},
}

local FileType = {
	{
		init = function(self)
			local filename = vim.api.nvim_buf_get_name(0)
			local extension = vim.fn.fnamemodify(filename, ":e")
			self.icon, self.icon_color =
				require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
		end,
		provider = function(self)
			return " " .. self.icon and (self.icon .. " ")
		end,
		hl = function(self)
			return { fg = self.icon_color }
		end,
	},
	{
		provider = function()
			return vim.bo.filetype .. "  "
		end,
	},
}

local GitStatus = {
	{
		provider = function(self)
			local count = self.status_dict.added or 0
			return count > 0 and (get_icon("GitAdd") .. " " .. count .. " ")
		end,
		hl = { fg = "green" },
	},
	{
		provider = function(self)
			local count = self.status_dict.removed or 0
			return count > 0 and (get_icon("GitDelete") .. " " .. count .. " ")
		end,
		hl = { fg = "red" },
	},
	{
		provider = function(self)
			local count = self.status_dict.changed or 0
			return count > 0 and (get_icon("GitChange") .. " " .. count .. " ")
		end,
		hl = { fg = "yellow" },
	},
}

local Diagnostics = {
	condition = conditions.has_diagnostics,
	static = {
		error_icon = get_icon("DiagnosticError"),
		warn_icon = get_icon("DiagnosticWarn"),
		info_icon = get_icon("DiagnosticInfo"),
		hint_icon = get_icon("DiagnosticHint"),
	},
	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,
	update = { "DiagnosticChanged", "BufEnter" },

	{
		provider = function(self)
			return self.errors > 0 and (self.error_icon .. " " .. self.errors .. " ")
		end,
		hl = { fg = "red1" },
	},
	{
		provider = function(self)
			return self.warnings > 0 and (self.warn_icon .. " " .. self.warnings .. " ")
		end,
		hl = { fg = "yellow" },
	},
	{
		provider = function(self)
			return self.info > 0 and (self.info_icon .. " " .. self.info .. " ")
		end,
		hl = { fg = "blue2" },
	},
	{
		provider = function(self)
			return self.hints > 0 and (self.hint_icon .. " " .. self.hints .. " ")
		end,
		hl = { fg = "teal" },
	},
	{
		provider = " ",
	},
}

local LSPActive = {
	condition = conditions.lsp_attached,
	update = { "LspAttach", "LspDetach" },

	-- provider = " LSP, Formatter, Linter",
	provider = function()
		local names = {}
		for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
			table.insert(names, server.name)
		end
		return get_icon("ActiveLSP") .. "  " .. table.concat(names, ", ") .. "  "
	end,
}

local Ruler = {
	-- %l = current line number
	-- %L = number of lines in the buffer
	-- %c = column number
	-- %P = percentage through file of displayed window
	provider = "%l:%c %P ",
}

local ScrollBar = {
	static = {
		sbar = { "󰝦", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪣", "󰪥" },
	},
	provider = function(self)
		local curr_line = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_line_count(0)
		local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
		return self.sbar[i]
	end,
	hl = { fg = "yellow" },
}

GitContext = utils.insert(GitContext, FileType, GitStatus)

local StatusLine = {
	hl = {
		bg = "bg_dark",
		fg = "fg_dark",
	},
	ViMode,
	GitContext,
	{
		provider = "%=",
	},
	Diagnostics,
	LSPActive,
	Ruler,
	ScrollBar,
}

return StatusLine
