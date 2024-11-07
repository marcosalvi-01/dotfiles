return {
	"leath-dub/snipe.nvim",
	keys = {
		{
			"<leader><leader>",
			function()
				require("snipe").open_buffer_menu()
			end,
			desc = "Open Snipe buffer menu",
		},
	},
	opts = {
		ui = {
			position = "center",
			open_win_override = {
				border = "rounded",
			},
		},
		hints = {
			dictionary = "crstneiadvjh.,lyfpuo",
		},
		sort = "default",
	},
}
