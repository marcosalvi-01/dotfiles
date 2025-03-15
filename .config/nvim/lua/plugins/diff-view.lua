return {
	"sindrets/diffview.nvim",
	opts = {
		enhanced_diff_hl = false,
		keymaps = {
			view = {
				{
					"n",
					"q",
					"<cmd>tabc<CR>",
					{ desc = "Close the diff" },
				},
			},
			file_panel = {
				{ "n", "q", "<cmd>tabc<CR>", { desc = "Close the panel" } },
				{
					"n",
					"t",
					function()
						require("diffview.actions").listing_style()
					end,
					{ desc = "Toggle file panel listing style" },
				},
			},
		},
		file_panel = {
			listing_style = "list", -- One of 'list' or 'tree'
			win_config = {
				position = "left",
				width = 30,
			},
		},
	},
	keys = {
		{
			"<leader>hd",
			function()
				local pos = vim.api.nvim_win_get_cursor(0)
				local line = pos[1]
				local col = pos[2]
				vim.cmd("DiffviewOpen")
				vim.cmd("DiffviewToggleFiles")
				vim.api.nvim_win_set_cursor(0, { line, col })
			end,
			desc = "Git Diff this file [Diffview]",
		},
	},
}
