return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration
	},
	keys = {
		{
			"<leader><BS>",
			function()
				vim.cmd("Neogit kind=replace")
			end,
			desc = "Open [N]eo[G]it window (Neogit)",
		},
	},
	config = function()
		require("neogit").setup({
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
		})

		require("diffview").setup({
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
					{
						"n",
						"q",
						"<cmd>tabc<CR>",
						{ desc = "Close the panel" },
					},
				},
			},
		})

		return true
	end,
}
