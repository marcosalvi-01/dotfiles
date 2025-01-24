-- Declare a global function to retrieve the current directory
local function get_buf_name()
	local dir = require("oil").get_current_dir()
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	else
		-- Get the buffer name and strip the path to get only the file name
		local buf_name = vim.api.nvim_buf_get_name(0)
		local file_name = vim.fn.fnamemodify(buf_name, ":t")
		-- Check if the buffer is modified and add an icon if it is
		if vim.bo.modified then
			return file_name .. " ●"
		else
			return file_name
		end
	end
end

local colors = {
	background = "#282828",
	foreground = "#d4be98",
	taupe = "#504945",
	neutral_gray = "#32302f",
	beige = "#a89984",
	blue_green = "#7daea3",
	greenish = "#8ec07c",
	yellowish = "#d8a657",
	pinkish = "#d3869b",
	reddish = "#ea6962",
}

local bubbles_theme = {
	normal = {
		a = { fg = colors.background, bg = colors.greenish, gui = "bold" },
		b = { fg = colors.foreground, bg = colors.background, gui = "bold" },
		c = { fg = colors.foreground, bg = nil, gui = "bold" },
	},
	insert = { a = { fg = colors.background, bg = colors.blue_green, gui = "bold" } },
	visual = { a = { fg = colors.background, bg = colors.yellowish, gui = "bold" } },
	replace = { a = { fg = colors.background, bg = colors.pinkish, gui = "bold" } },
	command = { a = { fg = colors.background, bg = colors.reddish, gui = "bold" } },
	inactive = {
		a = { fg = colors.foreground, bg = colors.taupe, gui = "bold" },
		b = { fg = colors.foreground, bg = colors.background, gui = "bold" },
		c = { fg = colors.foreground, bg = nil, gui = "bold" },
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
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = "", right = "" }, right_padding = 2 },
					{
						"branch",
						icon = "󰘬", -- Branch icon
						color = { fg = colors.foreground, bg = colors.taupe, gui = "bold" },
						separator = { left = "", right = "" },
					},
				},
				lualine_b = {
					{ get_buf_name, separator = { right = "" } },
					{
						"diff",
						symbols = { added = "+", modified = "~", removed = "-" },
						diff_color = {
							added = { fg = colors.greenish, gui = "bold" },
							modified = { fg = colors.yellowish, gui = "bold" },
							removed = { fg = colors.reddish, gui = "bold" },
						},
						separator = { left = "", right = "" },
					},
				},
				lualine_c = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						diagnostics_color = {
							error = { fg = colors.reddish, gui = "bold" },
							warn = { fg = colors.yellowish, gui = "bold" },
							info = { fg = colors.blue_green, gui = "bold" },
							hint = { fg = colors.beige, gui = "bold" },
						},
					},
				},
				lualine_x = {
					{
						"encoding",
						color = { fg = colors.beige, bg = colors.background, gui = "bold" },
						separator = { left = "" },
					},
					{
						"fileformat",
						symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
						color = { fg = colors.beige, bg = colors.background, gui = "bold" },
						separator = { left = "" },
					},
				},
				lualine_y = {
					{ "filetype", color = { fg = colors.foreground, bg = colors.taupe, gui = "bold" } },
					{ "progress", color = { fg = colors.foreground, bg = colors.taupe, gui = "bold" } },
				},
				lualine_z = {
					{ "location", separator = { left = "", right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { get_buf_name },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = { "man", "mason", "lazy", "quickfix" },
		})
	end,
}
