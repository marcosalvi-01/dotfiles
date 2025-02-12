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
	opts = {
		characters = "neiatsrchd0123456789",
		reverse_sort = false,
	},
}
