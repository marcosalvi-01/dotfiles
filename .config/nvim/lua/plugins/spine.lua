return {
	-- dir = "~/spine",
	"marcosalvi-01/spine",
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
