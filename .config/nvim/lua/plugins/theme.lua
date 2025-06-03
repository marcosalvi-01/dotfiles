return {
	"sainnhe/gruvbox-material",
	lazy = false,
	priority = 1000,
	config = function()
		-- Base theme configuration
		vim.g.gruvbox_material_background = "medium"
		vim.g.gruvbox_material_foreground = "material"
		vim.g.gruvbox_material_transparent_background = 2
		vim.g.gruvbox_material_enable_italic = false
		vim.g.gruvbox_material_disable_terminal_colors = 1
		vim.g.gruvbox_material_better_performance = 1

		-- Create an autocommand to apply custom highlights when the colorscheme is applied
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
			pattern = "gruvbox-material",
			callback = function()
				local colors = require("utils.palette")

				local hl = vim.api.nvim_set_hl

				-- Floating windows and borders
				hl(0, "NormalFloat", {})
				hl(0, "FloatBorder", { fg = colors.fg })
				hl(0, "FloatTitle", { fg = colors.fg, bg = nil })
				hl(0, "TelescopeBorder", { fg = colors.fg })

				-- Scrollbars and menus
				hl(0, "Pmenu", { bg = nil })
				hl(0, "PmenuSel", { bg = colors.bg.selection })
				hl(0, "PmenuThumb", { bg = colors.accent.gray })
				hl(0, "BlinkCmpGhostText", { fg = colors.bg.selection })

				-- Snacks plugin
				hl(0, "SnacksIndentScope", { fg = colors.accent.red })
				hl(0, "SnacksPickerBorder", { fg = colors.fg })
				hl(0, "SnacksPickerListCursorLine", { link = "Visual" })
				hl(0, "SnacksPickerToggleIgnored", { link = "Title" })
				hl(0, "SnacksPickerToggleHidden", { link = "Title" })
				hl(0, "SnacksPickerMatch", { bold = true, fg = colors.accent.green, bg = colors.accent.teal })
				-- Dashboard
				hl(0, "SnacksDashboardHeader", { bold = true, fg = colors.accent.blue })
				hl(0, "SnacksDashboardFooter", { bold = true, fg = colors.accent.yellow })
				hl(0, "SnacksDashboardSpecial", { bold = true, fg = colors.accent.red })
				hl(0, "SnacksDashboardFile", { bold = true, fg = colors.accent.green })
				hl(0, "SnacksDashboardDesc", { bold = true, fg = colors.accent.purple })
				hl(0, "SnacksDashboardIcon", { bold = true, fg = colors.accent.yellow })
				hl(0, "SnacksDashboardKey", { bold = true, fg = colors.accent.red })

				-- Debug line
				hl(0, "DebugPrintLine", { bg = "#363629", italic = true })

				-- Diffview
				hl(0, "DiffText", { bg = colors.accent.teal })

				-- Pathfinder (gf) plugin
				hl(0, "PathfinderDim", { link = "Comment" })
				hl(0, "PathfinderHighlight", { link = "Fg" })
				hl(0, "PathfinderNextKey", { bg = colors.accent.yellow, fg = colors.bg.base, bold = true })
				hl(0, "PathfinderFutureKeys", { bg = colors.accent.yellow, fg = colors.bg.base, bold = true })

				-- Search highlighting
				hl(0, "Search", { bg = colors.accent.teal })
				hl(0, "IncSearch", { bg = colors.accent.orange })
				hl(0, "HighlightedyankRegion", { bg = colors.accent.red, fg = colors.bg.base })

				-- Diagnostics
				local diagnostic_groups = {
					{ name = "Warn", color = colors.accent.yellow },
					{ name = "Hint", color = colors.accent.green },
					{ name = "Info", color = colors.accent.blue },
					{ name = "Error", color = colors.accent.red },
				}

				for _, diag in ipairs(diagnostic_groups) do
					hl(0, "DiagnosticUnderline" .. diag.name, { sp = diag.color, underline = true })
					hl(0, "LspDiagnosticUnderline" .. diag.name, { link = "DiagnosticUnderline" .. diag.name })
				end

				-- Multi-cursor plugin
				local multi_cursor_groups = {
					"Cursor",
					"Visual",
					"Sign",
				}

				for _, group in ipairs(multi_cursor_groups) do
					hl(0, "MultiCursor" .. group, { link = group })
					hl(0, "MultiCursorDisabled" .. group, { link = "Visual" })
				end

				-- Todo highlighting
				hl(0, "MiniHipatternsTodo", { bg = colors.accent.purple, bold = true, fg = colors.bg.base })

				-- Folded lines
				hl(0, "Folded", { fg = nil, bg = colors.bg.light })

				-- LSP current word highlighting
				hl(0, "CurrentWord", { bg = colors.bg.light, bold = true })
				hl(0, "LspReferenceText", { link = "CurrentWord" })
				hl(0, "LspReferenceRead", { link = "CurrentWord" })
				hl(0, "LspReferenceWrite", { link = "CurrentWord" })

				-- Noice plugin
				hl(0, "NoiceCmdlinePopupBorder", { link = "FloatBorder" })
				hl(0, "NoiceCmdlinePopupTitle", { link = "Title" })
				hl(0, "NoiceCmdlinePopupBorderSearch", { link = "FloatBorder" })
			end,
		})

		-- Apply the colorscheme
		vim.cmd.colorscheme("gruvbox-material")
	end,
}
