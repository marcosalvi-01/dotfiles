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
					-- Fix floating windows borders
					local bg_color = "#282828"
					local fg_color = "#d4be98"

					-- Make the popups bordered and have no background
					vim.api.nvim_set_hl(0, "NormalFloat", {})
					vim.api.nvim_set_hl(0, "FloatBorder", { fg = fg_color })
					vim.api.nvim_set_hl(0, "FloatTitle", { fg = fg_color, bg = nil })
					vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = fg_color })
					vim.api.nvim_set_hl(0, "Pmenu", { bg = nil })
					vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#504945" })
					vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#a89984" })
					vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#504945" })
					vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#ea6962" })
					vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = fg_color })
					vim.api.nvim_set_hl(0, "DebugPrintLine", { fg = "#d8a657" })
					vim.api.nvim_set_hl(0, "MiniHipatternsTodo", {
						bg = "#d3869b",
						bold = true,
						cterm = { bold = true },
						ctermbg = 167,
						ctermfg = 235,
						fg = "#282828",
					})
				end,
			})

			-- Apply the colorscheme
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
}
