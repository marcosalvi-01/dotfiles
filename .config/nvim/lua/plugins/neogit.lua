return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration

		"nvim-telescope/telescope.nvim", -- optional
	},
	config = function()
		require("neogit").setup({
			signs = {
				-- { CLOSED, OPENED }
				hunk = { "", "" },
				item = { "", "" },
				section = { "", "" },
			},
			graph_style = "kitty",
		})
		vim.keymap.set("n", "<leader>ng", "<cmd>Neogit kind=replace<cr>", { desc = "Open [N]eo[G]it window (Neogit)" })

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
