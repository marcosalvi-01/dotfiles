return {
	"stevearc/quicker.nvim",
	ft = "qf",
	---@module "quicker"
	---@type quicker.SetupOptions
	opts = {
		keys = {
			{
				">",
				function()
					require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
				end,
				desc = "Expand quickfix context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Collapse quickfix context",
			},
		},
		borders = {
			vert = "│",
			-- Strong headers separate results from different files
			strong_header = "─",
			strong_cross = "┼",
			strong_end = "┤",
			-- Soft headers separate results within the same file
			soft_header = "┈",
			soft_cross = "┼",
			soft_end = "┤",
		},
	},
	keys = {
		{
			"<leader>q",
			function()
				require("quicker").toggle({ focus = true })
				if vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].quickfix == 1 then
					vim.cmd("Refresh")
				end
			end,
		},
		{
			"<leader>l",
			function()
				require("quicker").toggle({ focus = true, loclist = true })
				if vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 1 then
					vim.cmd("Refresh")
				end
			end,
		},
	},
}
