return {
	"tpope/vim-fugitive",
	keys = {
		{
			"<leader>gs",
			function()
				vim.cmd.Git()
			end,
			desc = "Open [G]it [S]tatus",
		},
	},
	-- config = function()
	-- 	vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "[G]it [S]tatus" })
	-- end,
}
