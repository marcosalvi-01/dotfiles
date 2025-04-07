return {
	"andrewferrier/debugprint.nvim",
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
		display_counter = false,
		display_snippet = true,
		print_tag = "DEBUGPRINT",
	},
}
