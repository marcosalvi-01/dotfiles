-- Declare a global function to retrieve the current directory
local function get_buf_name()
	local dir = require("oil").get_current_dir()
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	else
		-- Get the buffer name and strip the path to get only the file name
		local buf_name = vim.api.nvim_buf_get_name(0)
		return vim.fn.fnamemodify(buf_name, ":t")
	end
end

local colors = {
	background = "#282828", -- Dark background, unchanged
	foreground = "#e5c7b2", -- Brighter and warmer beige foreground (slightly adjusted)
	beige = "#f2d5bb", -- Slightly warmer beige for better contrast
	cream = "#f8e9d1", -- Softer and lighter cream for highlights
	olive = "#a3a12b", -- Brighter olive for better readability
	taupe = "#6e635d", -- A slightly lighter taupe for secondary elements
	neutral_gray = "#3e3a36", -- Neutral gray with a touch of warmth for inactive elements
	yellow_light = "#fabd2f", -- Bright yellow, unchanged for emphasis
	yellow_dark = "#d79921", -- Muted yellow, unchanged for balance
	red = "#993300",
}
local bubbles_theme = {
	normal = {
		a = { fg = colors.foreground, bg = colors.background },
		b = { fg = colors.foreground, bg = colors.taupe },
		c = { fg = colors.beige, bg = nil },
	},
	insert = { a = { fg = colors.background, bg = colors.cream } },
	visual = { a = { fg = colors.background, bg = colors.beige } },
	replace = { a = { fg = colors.foreground, bg = colors.olive } },
	command = { a = { fg = colors.background, bg = colors.foreground } },
	inactive = {
		a = { fg = colors.foreground, bg = nil },
		b = { fg = colors.foreground, bg = nil },
		c = { fg = colors.foreground, bg = nil },
	},
}

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = bubbles_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = "" }, right_padding = 2 },
				},
				lualine_b = {
					get_buf_name,
					--"filename",
					{
						"branch",
						icon = "⎇", -- Branch icon
						color = { fg = colors.foreground, bg = colors.taupe },
					},
					{
						"diff",
						symbols = { added = "+", modified = "~", removed = "-" },
						diff_color = {
							added = { fg = colors.yellow_light, bg = colors.taupe },
							modified = { fg = colors.beige, bg = colors.taupe },
							removed = { fg = colors.olive, bg = colors.taupe },
						},
					},
				},
				lualine_c = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						diagnostics_color = {
							error = { fg = colors.red, bg = colors.background },
							warn = { fg = colors.yellow_dark, bg = colors.background },
							info = { fg = colors.yellow_light, bg = colors.background },
							hint = { fg = colors.beige, bg = colors.background },
						},
					},
				},
				lualine_x = {
					{ "encoding", fg = colors.beige, bg = colors.background },
					{
						"fileformat",
						symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
						fg = colors.beige,
						bg = colors.background,
					},
				},
				lualine_y = {
					{ "filetype", fg = colors.foreground, bg = colors.taupe },
					{ "progress", fg = colors.foreground, bg = colors.taupe },
				},
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = {
					get_buf_name,
					--"filename"
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = { "oil", "fugitive", "man", "mason", "lazy", "quickfix" },
		})
	end,
}
