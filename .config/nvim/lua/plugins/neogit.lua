return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration

		-- Only one of these is needed.
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
		})
		vim.keymap.set(
			"n",
			"<leader>ng",
			"<cmd>Neogit kind=replace<cr>",
			{ desc = "Open [N]eo[G]it floating window (Neogit)" }
		)

		return true
	end,
}
