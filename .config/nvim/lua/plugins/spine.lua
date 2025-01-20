return {
	-- dir = "~/spine",
	"marcosalvi-01/spine",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<BS>",
			function()
				require("spine").Open()
			end,
			desc = "Open Snipe buffer menu",
		},
	},
	config = function()
		vim.keymap.set("n", "<BS>", function()
			require("spine").Open()
		end)
	end,
}
