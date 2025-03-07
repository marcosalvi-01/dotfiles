return {
	-- dir = "~/spine",
	"marcosalvi-01/spine",
	branch = "refactor",
	keys = {
		{
			"<leader><BS>",
			function()
				require("spine").open()
			end,
			desc = "Open Snipe buffer menu",
		},
		{
			"<leader><cr>",
			function()
				require("spine").api.add_current_buffer()
			end,
			desc = "Add current buffer to Spine list",
		},
	},
	opts = {
		characters = "neiatsrchd0123456789",
		reverse_sort = false,
		auto = false,
	},
}
