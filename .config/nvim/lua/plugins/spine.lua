return {
	dir = "~/spine",
	keys = {
		{
			"<leader><leader>",
			function()
				require("spine").Open()
			end,
			desc = "Open Snipe buffer menu",
		},
	},
	config = function()
		vim.keymap.set("n", "<leader><leader>", function()
			require("spine").Open()
		end)
	end,
}
