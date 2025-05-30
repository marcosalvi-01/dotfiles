-- Helper functions
local function show_macro_recording()
	local recording_register = vim.fn.reg_recording()
	if recording_register == "" then
		return ""
	else
		return "󰑊 @" .. recording_register
	end
end

-- Function to retrieve the current directory or buffer name
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

local colors = require("utils.palette")

-- Define lualine theme based on our unified colors
local bubbles_theme = {
	normal = {
		a = { fg = colors.bg.base, bg = colors.accent.green, gui = "bold" },
		b = { fg = colors.fg, bg = colors.bg.base, gui = "bold" },
		c = { fg = colors.fg, bg = nil, gui = "bold" },
	},
	insert = { a = { fg = colors.bg.base, bg = colors.accent.blue, gui = "bold" } },
	visual = { a = { fg = colors.bg.base, bg = colors.accent.yellow, gui = "bold" } },
	replace = { a = { fg = colors.bg.base, bg = colors.accent.purple, gui = "bold" } },
	command = { a = { fg = colors.bg.base, bg = colors.accent.red, gui = "bold" } },
	inactive = {
		a = { fg = colors.fg, bg = colors.bg.selection, gui = "bold" },
		b = { fg = colors.fg, bg = colors.bg.base, gui = "bold" },
		c = { fg = colors.fg, bg = nil, gui = "bold" },
	},
}

return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = bubbles_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
				globalstatus = true,
				always_show_tabline = false,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						separator = { left = "", right = "" },
						right_padding = 2,
					},
					{
						"branch",
						icon = "󰘬",
						color = { fg = colors.fg, bg = colors.bg.selection, gui = "bold" },
						separator = { left = "", right = "" },
					},
				},
				lualine_b = {
					{ get_buf_name, separator = { right = "" } },
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = {
							added = { fg = colors.accent.green, gui = "bold" },
							modified = { fg = colors.accent.yellow, gui = "bold" },
							removed = { fg = colors.accent.red, gui = "bold" },
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
							error = { fg = colors.accent.red, gui = "bold" },
							warn = { fg = colors.accent.yellow, gui = "bold" },
							info = { fg = colors.accent.blue, gui = "bold" },
							hint = { fg = colors.accent.gray, gui = "bold" },
						},
					},
					{
						show_macro_recording,
						color = { fg = colors.accent.red, gui = "bold" },
					},
				},
				lualine_x = {
					{
						"encoding",
						color = { fg = colors.accent.gray, bg = colors.bg.base, gui = "bold" },
						separator = { left = "" },
					},
					{
						"fileformat",
						symbols = { unix = "", dos = "", mac = "" },
						color = { fg = colors.accent.gray, bg = colors.bg.base, gui = "bold" },
						separator = { left = "" },
					},
				},
				lualine_y = {
					{
						"filetype",
						color = { fg = colors.fg, bg = colors.bg.selection, gui = "bold" },
					},
					{
						"progress",
						color = { fg = colors.fg, bg = colors.bg.selection, gui = "bold" },
					},
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
			tabline = {
				lualine_a = {
					{
						"tabs",
						mode = 2, -- Show tab name + number
						max_length = vim.o.columns,
						tabs_color = {
							active = { fg = colors.bg.base, bg = colors.accent.green, gui = "bold" },
							inactive = { fg = colors.fg, bg = colors.bg.selection, gui = "bold" },
						},
						separator = { left = "", right = "" },
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { "man", "quickfix" },
		})
	end,
}
