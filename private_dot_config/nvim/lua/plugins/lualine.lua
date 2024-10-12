-- Customized Bubbles config for lualine with brown theme and enhanced git info
-- Based on lokesh-krishna's config
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  brown_dark = '#2C2117',
  brown_light = '#8B7355',
  beige = '#D2B48C',
  cream = '#FAEBD7',
  rust = '#8B4513',
  olive = '#6B8E23',
  sage = '#9CA97E',
  taupe = '#483C32',
  coffee = '#6F4E37',
}

local bubbles_theme = {
	normal = {
		a = { fg = colors.cream, bg = colors.coffee },
		b = { fg = colors.cream, bg = colors.taupe },
		c = { fg = colors.beige, bg = colors.brown_dark },
	},
	insert = { a = { fg = colors.brown_dark, bg = colors.sage } },
	visual = { a = { fg = colors.brown_dark, bg = colors.beige } },
	replace = { a = { fg = colors.cream, bg = colors.rust } },
	command = { a = { fg = colors.brown_dark, bg = colors.olive } },
	inactive = {
		a = { fg = colors.beige, bg = colors.brown_dark },
		b = { fg = colors.beige, bg = colors.brown_dark },
		c = { fg = colors.beige, bg = colors.brown_dark },
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
					"filename",
					{
						"branch",
						icon = "⎇", -- Branch icon
						color = { fg = colors.cream, bg = colors.taupe },
					},
					{
						"diff",
						symbols = { added = "+", modified = "~", removed = "-" }, -- Git status symbols
						diff_color = {
							added = { fg = colors.sage, bg = colors.taupe },
							modified = { fg = colors.beige, bg = colors.taupe },
							removed = { fg = colors.rust, bg = colors.taupe },
						},
					},
				},
				lualine_c = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						diagnostics_color = {
							error = { fg = colors.rust, bg = colors.brown_dark },
							warn = { fg = colors.olive, bg = colors.brown_dark },
							info = { fg = colors.sage, bg = colors.brown_dark },
							hint = { fg = colors.beige, bg = colors.brown_dark },
						},
					},
				},
				lualine_x = {
					{ "encoding", fg = colors.beige, bg = colors.brown_dark },
					{
						"fileformat",
						symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
						fg = colors.beige,
						bg = colors.brown_dark,
					},
				},
				lualine_y = {
					{ "filetype", fg = colors.cream, bg = colors.taupe },
					{ "progress", fg = colors.cream, bg = colors.taupe },
				},
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = {},
		})
	end,
}
