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
	config = function()
		vim.keymap.set("n", "<BS>", function()
			require("spine").Open()
		end)
	end,
}
