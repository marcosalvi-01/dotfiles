return {
	"leath-dub/snipe.nvim",
	keys = {
		{
			"<leader>u<leader>",
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
			text_align = "file-first",
			-- preselect = function()
			-- 	require("snipe").preselect_by_classifier("#")
			-- end,
		},
		hints = {
			dictionary = "neiatsrch.,-dvjw",
		},
		sort = "default",
		navigate = {
			open_vsplit = "<C-s>"
		}
	},
}
