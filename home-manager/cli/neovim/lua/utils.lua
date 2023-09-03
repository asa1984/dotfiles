local M = {}

-- Refer to AstroNvim
local icons = {
	ActiveLSP = "",
	ActiveTS = "",
	ArrowLeft = "",
	ArrowRight = "",
	Bookmarks = "",
	BufferClose = "󰅖",
	DapBreakpoint = "",
	DapBreakpointCondition = "",
	DapBreakpointRejected = "",
	DapLogPoint = ".>",
	DapStopped = "󰁕",
	Debugger = "",
	DefaultFile = "󰈙",
	Diagnostic = "󰒡",
	DiagnosticError = "",
	DiagnosticHint = "󰌵",
	DiagnosticInfo = "󰋼",
	DiagnosticWarn = "",
	Ellipsis = "…",
	FileNew = "",
	FileModified = "",
	FileReadOnly = "",
	FoldClosed = "",
	FoldOpened = "",
	FoldSeparator = " ",
	FolderClosed = "",
	FolderEmpty = "",
	FolderOpen = "",
	Git = "󰊢",
	GitAdd = "",
	GitBranch = "",
	GitChange = "",
	GitConflict = "",
	GitDelete = "",
	GitIgnored = "◌",
	GitRenamed = "➜",
	GitSign = "▎",
	GitStaged = "✓",
	GitUnstaged = "✗",
	GitUntracked = "★",
	LSPLoaded = "",
	LSPLoading1 = "",
	LSPLoading2 = "󰀚",
	LSPLoading3 = "",
	MacroRecording = "",
	Package = "󰏖",
	Paste = "󰅌",
	Refresh = "",
	Search = "",
	SearchText = "󰺯",
	Selected = "❯",
	Session = "󱂬",
	Sort = "󰒺",
	Spellcheck = "󰓆",
	Tab = "󰓩",
	TabClose = "󰅙",
	Terminal = "",
	Window = "",
	WordFile = "󰈭",

	Lazy = "󰒲 ",
}

--! @param icon_name string
--! @return string
function M.get_icon(icon_name)
	return icons[icon_name] or ""
end

return M
