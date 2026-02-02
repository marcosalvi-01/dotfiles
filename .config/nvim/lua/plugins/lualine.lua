-- Helper functions
local function show_macro_recording()
	local recording_register = vim.fn.reg_recording()
	if recording_register == "" then
		return ""
	else
		return "󰑊 @" .. recording_register
	end
end

local function get_buf_name()
	local bufname = vim.api.nvim_buf_get_name(0)

	-- If the buffer has no name (e.g. empty/new buffer), show cwd
	if bufname == "" then
		return vim.fn.fnamemodify(vim.loop.cwd(), ":~")
	end

	if bufname:find("#toggleterm") then
		local shell = bufname:match("/([^/]+);#toggleterm")
		return "  " .. shell
	end

	local filename = vim.fn.fnamemodify(bufname, ":t")
	if vim.bo.modified then
		return filename .. " ●"
	end
	return filename
end

local colors = require("utils.palette")

-- Define lualine theme based on our unified colors
local bubbles_theme = {
	normal = {
		a = { fg = colors.bg.base, bg = colors.accent.green },
		b = { fg = colors.fg, bg = colors.bg.base },
		c = { fg = colors.fg, bg = nil },
	},
	insert = { a = { fg = colors.bg.base, bg = colors.accent.blue } },
	visual = { a = { fg = colors.bg.base, bg = colors.accent.yellow } },
	replace = { a = { fg = colors.bg.base, bg = colors.accent.purple } },
	command = { a = { fg = colors.bg.base, bg = colors.accent.red } },
	inactive = {
		a = { fg = colors.fg, bg = colors.bg.selection },
		b = { fg = colors.fg, bg = colors.bg.base },
		c = { fg = colors.fg, bg = nil },
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
						color = { fg = colors.fg, bg = colors.bg.selection },
						separator = { left = "", right = "" },
					},
				},
				lualine_b = {
					{ get_buf_name, separator = { right = "" } },
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = {
							added = { fg = colors.accent.green },
							modified = { fg = colors.accent.yellow },
							removed = { fg = colors.accent.red },
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
							error = { fg = colors.accent.red },
							warn = { fg = colors.accent.yellow },
							info = { fg = colors.accent.blue },
							hint = { fg = colors.accent.gray },
						},
					},
					{
						show_macro_recording,
						color = { fg = colors.accent.red },
					},
				},
				lualine_x = {
					{
						"fileformat",
						symbols = { unix = "", dos = "", mac = "" },
						color = { fg = colors.accent.gray, bg = colors.bg.base },
						separator = { left = "" },
					},
					{
						"searchcount",
						color = { fg = colors.accent.gray, bg = colors.bg.base },
						separator = { left = "" },
					},
				},
				lualine_y = {
					{
						"filetype",
						color = { fg = colors.fg, bg = colors.bg.selection },
					},
					{
						"progress",
						color = { fg = colors.fg, bg = colors.bg.selection },
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
							active = { fg = colors.bg.base, bg = colors.accent.green },
							inactive = { fg = colors.fg, bg = colors.bg.selection },
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
