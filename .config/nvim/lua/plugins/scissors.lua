return {
	"chrisgrieser/nvim-scissors",
	dependencies = "folke/snacks.nvim",
	opts = {
		snippetDir = "~/.config/nvim/snips/",
		backdrop = {
			enabled = false,
		},
		jsonFormatter = "jq",
		editSnippetPopup = {
			height = 0.4,
			width = 0.6,
			keymaps = {
				cancel = "<esc>",
				saveChanges = "<CR>",
				goBackToSearch = "<C-o>",
				deleteSnippet = "<C-d>",
				duplicateSnippet = "<C-y>",
				openInFile = "<C-f>",
				insertNextPlaceholder = "<C-p>",
				showHelp = "?",
			},
		},
	},
	keys = {
		{
			"<leader>se",
			function()
				require("scissors").editSnippet()
			end,
			{ desc = "Edit snippet [Scissors]" },
		},
		{
			"<leader>sa",
			function()
				require("scissors").addNewSnippet()
			end,
			mode = { "n", "x" },
			{ desc = "Add new snippet [Scissors]" },
		},
	},
}
