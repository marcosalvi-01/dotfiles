return {
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_foreground = "material"

			vim.g.gruvbox_material_transparent_background = 2

			vim.g.gruvbox_material_enable_italic = false

			-- Enable better performance
			vim.g.gruvbox_material_better_performance = 1

			-- Create an autocommand group for our custom highlights
			local grpid = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {})

			-- Create an autocommand to apply custom highlights when the colorscheme is applied
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = grpid,
				pattern = "gruvbox-material",
				callback = function()
					local hl = vim.api.nvim_set_hl

					-- Fix floating windows borders
					local bg_color = "#282828"
					local fg_color = "#d4be98"

					-- Make the popups bordered and have no background
					hl(0, "NormalFloat", {})
					hl(0, "FloatBorder", { fg = fg_color })
					hl(0, "FloatTitle", { fg = fg_color, bg = nil })
					hl(0, "TelescopeBorder", { fg = fg_color })

					-- scroll bars
					hl(0, "Pmenu", { bg = nil })
					hl(0, "PmenuSel", { bg = "#504945" })
					hl(0, "PmenuThumb", { bg = "#a89984" })

					-- autocmpletion ghost text
					hl(0, "BlinkCmpGhostText", { fg = "#504945" })

					-- snacks
					hl(0, "SnacksIndentScope", { fg = "#ea6962" })
					hl(0, "SnacksPickerBorder", { fg = fg_color })
					hl(0, "SnacksPickerListCursorLine", { link = "Visual" })
					hl(0, "SnacksPickerToggleIgnored", { link = "Title" })
					hl(0, "SnacksPickerToggleHidden", { link = "Title" })

					-- debug linen
					hl(0, "DebugPrintLine", { fg = "#d8a657", bg = "#363629" })

					-- diffview
					hl(0, "DiffText", { bg = "#355F59", ctermbg = 109, ctermfg = 235 })

					-- pathfinder (gf)
					hl(0, "PathfinderDim", { link = "Comment" })
					hl(0, "PathfinderHighlight", { link = "Fg" })
					hl(0, "PathfinderNextKey", { bg = "#d8a657", fg = bg_color, bold = true })
					hl(0, "PathfinderFutureKeys", { bg = "#d8a657", fg = bg_color, bold = true })

					-- search highlight
					hl(0, "Search", { bg = "#355F59", ctermbg = 142, ctermfg = 235 })
					hl(0, "IncSearch", { bg = "#5B4D28", ctermbg = 142, ctermfg = 235 })

					-- highlight yank
					hl(0, "HighlightedyankRegion", {bg = "#EA6962", fg = bg_color})

					-- diagnostic underline not curly
					hl(0, "DiagnosticUnderlineWarn", { sp = "#D8A657", cterm = { underline = true }, underline = true })
					hl(0, "DiagnosticUnderlineHint", { cterm = { underline = true }, sp = "#A9B665", underline = true })
					hl(0, "DiagnosticUnderlineInfo", { cterm = { underline = true }, sp = "#7DAEA3", underline = true })
					hl(
						0,
						"DiagnosticUnderlineError",
						{ cterm = { underline = true }, sp = "#EA6962", underline = true }
					)
					hl(0, "LspDiagnosticUnderlineWarn", { link = "DiagnosticUnderlineWarn" })
					hl(0, "LspDiagnosticUnderlineHint", { link = "DiagnosticUnderlineHint" })
					hl(0, "LspDiagnosticUnderlineInfo", { link = "DiagnosticUnderlineInfo" })
					hl(0, "LspDiagnosticUnderlineError", { link = "DiagnosticUnderlineError" })

					-- multicursor stuff
					hl(0, "MultiCursorCursor", { link = "Cursor" })
					hl(0, "MultiCursorVisual", { link = "Visual" })
					hl(0, "MultiCursorSign", { link = "SignColumn" })
					hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
					hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
					hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

					-- todo pink
					hl(0, "MiniHipatternsTodo", {
						bg = "#d3869b",
						bold = true,
						cterm = { bold = true },
						ctermbg = 167,
						ctermfg = 235,
						fg = bg_color,
					})

					-- folded lines
					hl(0, "Folded", { fg = nil, bg = "#292929" })

					-- lsp current word highlight
					hl(0, "LspReferenceText", { link = "CurrentWord" })
					hl(0, "LspReferenceRead", { link = "CurrentWord" })
					hl(0, "LspReferenceWrite", { link = "CurrentWord" })
					hl(0, "CurrentWord", { bg = "#292929", bold = true })
				end,
			})

			-- Apply the colorscheme
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
}
