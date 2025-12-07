return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = {
			"ToggleTerm",
		},
		opts = {
			direction = "float",
			float_opts = {
				width = vim.o.columns - 1,
				height = vim.o.lines - 1,
				border = "none",
			},
			hide_numbers = false,
			open_mapping = nil,
			on_open = function(term)
				vim.bo[term.bufnr].buflisted = false
				vim.wo.number = true
				vim.wo.relativenumber = true
			end,
			on_close = function()
				vim.cmd("clearjumps")
			end,
			persist_size = false,
			persist_mode = false,
			start_in_insert = true,
		},
		keys = {
			{
				"<leader>t",
				function()
					require("toggleterm").toggle(1)
				end,
				desc = "Toggle full-screen terminal",
			},
		},
	},
}
