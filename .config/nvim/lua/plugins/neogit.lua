return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
	},
	keys = {
		{
			"<leader>n",
			function()
				vim.cmd("Neogit kind=tab")
			end,
			desc = "Open [N]eogit window (Neogit)",
		},
	},
	cmd = {
		"Neogit",
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
