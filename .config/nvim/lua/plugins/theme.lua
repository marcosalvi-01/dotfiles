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
					vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#a89984" })
					vim.api.nvim_set_hl(0, "DebugPrintLine", { fg = "#d8a657" })
				end,
			})

			-- Apply the colorscheme
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	-- {
	-- 	"rebelot/kanagawa.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("kanagawa").setup({
	-- 			theme = "wave", -- Load "wave" theme when 'background' option is not set
	-- 			background = { -- map the value of 'background' option to a theme
	-- 				dark = "wave", -- try "dragon" !
	-- 				light = "lotus",
	-- 			},
	--
	-- 			-- Transparent background
	-- 			transparent = false,
	-- 			colors = {
	-- 				theme = {
	-- 					all = {
	-- 						ui = {
	-- 							bg_gutter = "none",
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	--
	-- 			overrides = function(colors)
	-- 				local theme = colors.theme
	-- 				return {
	-- 					NormalFloat = { bg = "none" },
	-- 					FloatBorder = { bg = "none" },
	-- 					FloatTitle = { bg = "none" },
	--
	-- 					-- Save an hlgroup with dark background and dimmed foreground
	-- 					-- so that you can use it where your still want darker windows.
	-- 					-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
	-- 					NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
	--
	-- 					-- Popular plugins that open floats will link to NormalFloat by default;
	-- 					-- set their background accordingly if you wish to keep them dark and borderless
	-- 					LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
	-- 					MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
	--
	-- 					Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend }, -- add `blend = vim.o.pumblend` to enable transparency
	-- 					PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
	-- 					PmenuSbar = { bg = theme.ui.bg_m1 },
	-- 					PmenuThumb = { bg = theme.ui.bg_p2 },
	-- 				}
	-- 			end,
	-- 		})
	--
	-- 		vim.cmd("colorscheme kanagawa")
	-- 	end,
	-- },
}
