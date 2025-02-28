return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
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
		},
	},
	keys = {
		{
			"<leader>n",
			function()
				vim.cmd("Neogit kind=replace")
			end,
			desc = "Open [N]eogit window (Neogit)",
		},
	},
	opts = {
		signs = {
			hunk = { "", "" },
			item = { "", "" },
			section = { "", "" },
		},
		graph_style = "kitty",
		mappings = {
			status = {
				["<c-l>"] = "RefreshBuffer",
			},
		},
	},
}
