local utils = require("heirline.utils")
local conditions = require("heirline.conditions")
local get_icon = require("utils").get_icon

local FileIcon = {
	{
		init = function(self)
			local filename = self.filename
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
}

local FileName = {
	provider = function(self)
		local filename = self.filename
		filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
		return filename
	end,
	hl = function(self)
		return {
			bold = self.is_active or self.is_visible,
			italic = self.is_active or self.is_visible,
		}
	end,
}

local FileFlags = {
	{
		condition = function(self)
			return vim.api.nvim_buf_get_option(self.bufnr, "modified")
		end,
		provider = "[+]",
		hl = { fg = "yellow" },
	},
	{
		condition = function(self)
			return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
				or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
		end,
		provider = function(self)
			if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
				return " " .. get_icon("Terminal") .. " "
			else
				return get_icon("FileReadOnly")
			end
		end,
		hl = { fg = "orange" },
	},
}

local FileDiagnostics = {
	condition = conditions.has_diagnostics,
	static = {
		error_icon = get_icon("DiagnosticError"),
		warn_icon = get_icon("DiagnosticWarn"),
		info_icon = get_icon("DiagnosticInfo"),
		hint_icon = get_icon("DiagnosticHint"),
	},
	init = function(self)
		local bufnr = self.bufnr
		if #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR }) > 0 then
			self.diagnostic_icon = self.error_icon
			self.diagnostic_color = "red1"
		elseif #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN }) > 0 then
			self.diagnostic_icon = self.warn_icon
			self.diagnostic_color = "yellow"
		elseif #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }) > 0 then
			self.diagnostic_icon = self.hint_icon
			self.diagnostic_color = "teal"
		elseif #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO }) > 0 then
			self.diagnostic_icon = self.info_icon
			self.diagnostic_color = "blue2"
		else
			self.diagnostic_icon = ""
		end
	end,
	update = { "DiagnosticChanged", "BufEnter" },

	{
		provider = function(self)
			return " " .. self.diagnostic_icon .. " "
		end,
		hl = function(self)
			return {
				fg = self.diagnostic_color,
			}
		end,
	},
}

local Buffer = {
	init = function(self)
		self.filename = vim.api.nvim_buf_get_name(self.bufnr)
	end,
	hl = function(self)
		if self.is_active then
			return {
				bg = "bg",
				fg = "fg",
			}
		else
			return {
				bg = "bg_dark",
				fg = "comment",
			}
		end
	end,

	{ provider = "  " },
	FileIcon,
	FileName,
	FileFlags,
	FileDiagnostics,
	{ provider = "  " },
}

local TabLine = utils.make_buflist(
	Buffer,
	{ provider = "", hl = { fg = "gray" } }, -- left truncation
	{ provider = "", hl = { fg = "gray" } } -- right trunctation
)

return TabLine
