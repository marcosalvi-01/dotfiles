return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	dependencies = {
		"folke/snacks.nvim",
	},
	cmd = {
		"Yazi",
	},
	keys = {
		{
			"<m-left>",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Open yazi at the current file",
		},
		{
			"-",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Open yazi at the current file",
		},
		{
			-- Open in the current working directory
			"<leader>cw",
			"<cmd>Yazi cwd<cr>",
			desc = "Open the file manager in nvim's working directory",
		},
		{
			"<leader>yr",
			"<cmd>Yazi toggle<cr>",
			desc = "Resume the last yazi session",
		},
	},
	opts = {
		-- if you want to open yazi instead of netrw, see below for more info
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
			open_file_in_vertical_split = "<c-s>",
			grep_in_directory = false,
			replace_in_directory = false,
		},
		floating_window_scaling_factor = 1,
		yazi_floating_window_border = "none",
	},
	-- -- 👇 if you use `open_for_directories=true`, this is recommended
	-- init = function()
	--   -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
	--   vim.g.loaded_netrw = 1
	--   vim.g.loaded_netrwPlugin = 1
	-- end,
}
