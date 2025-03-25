return {
	"nmiguel/jqscratch.nvim",
	ft = "json",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {},
	keys = {
		{
			"<leader>jq",
			function()
				require("jqscratch").toggle()
			end,
			{ desc = "Toggle [J][Q] scratch" },
		},
	},
}
