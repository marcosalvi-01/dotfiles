return {
	"aaronik/treewalker.nvim",
	opts = {
		-- Whether to briefly highlight the node after jumping to it
		highlight = false,

		-- How long should above highlight last (in ms)
		highlight_duration = 250,

		-- The color of the above highlight. Must be a valid vim highlight group.
		highlight_group = "CursorLine",
	},
	keys = {
		{ "<m-up>", "<cmd>Treewalker Up<cr>", { silent = true } },
		{ "<m-down>", "<cmd>Treewalker Down<cr>", { silent = true } },
		{ "<m-left>", "<cmd>Treewalker Left<cr>", { silent = true } },
		{ "<m-right>", "<cmd>Treewalker Right<cr>", { silent = true } },
		-- { "<sm-up>", "<cmd>Treewalker SwapUp<cr>", { silent = true } },
		-- { "<sm-down>", "<cmd>Treewalker SwapDown<cr>", { silent = true } },
		-- { "<sm-left>", "<cmd>Treewalker SwapLeft<cr>", { silent = true } },
		-- { "<sm-right>", "<cmd>Treewalker SwapRight<cr>", { silent = true } },
	},
}
