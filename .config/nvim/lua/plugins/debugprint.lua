return {
	"andrewferrier/debugprint.nvim",
	event = "VeryLazy",
	dependencies = {
		"echasnovski/mini.nvim",

		"folke/snacks.nvim",
	},
	-- highlighting depends on mini.hipatterns
	opts = {
		keymaps = {
			normal = {
				plain_below = "<leader>dh", -- [D]ebug [H]ere
				plain_above = "<leader>dH",
				variable_below = "<leader>dv", -- [D]ebug [V]ariable
				variable_above = "<leader>dV",
				variable_below_alwaysprompt = "<leader>da", -- [D]ebug [A]sk
				variable_above_alwaysprompt = "<leader>dA",
				textobj_below = "<leader>do", -- [D]ebug Text[O]bject
				textobj_above = "<leader>dO",
				toggle_comment_debug_prints = "<leader>dt", -- [D]ebug [T]oggle
				delete_debug_prints = "<leader>dd", -- [D]ebug [D]elete
			},
			insert = {
				plain = "",
				variable = "",
			},
			visual = {
				variable_below = "<leader>dv",
				variable_above = "<leader>dV",
			},
		},
		picker = "snacks.picker",
		display_counter = false,
		display_snippet = true,
		print_tag = "DEBUGPRINT",
	},

	keys = {
		-- Add all matches in the document
		{
			"<leader>ds",
			function()
				vim.cmd("Debugprint search")
			end,
			desc = "Search debugprint statements [DEBUGPRINT]",
		},
	},
}
