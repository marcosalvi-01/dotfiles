return {
	"aserowy/tmux.nvim",
	config = function()
		local tmux = require("tmux").setup({
			navigation = {
				-- enables default keybindings (C-hjkl) for normal mode
				enable_default_keybindings = false,
			},
			resize = {
				enable_default_keybindings = false,
			},
			-- IMPORTANT: sync with the system clipboard
			copy_sync = {
				redirect_to_clipboard = true,
			},
		})

		require("tmux.keymaps").register("n", {
			["<C-Left>"] = [[<cmd>lua require'tmux'.move_left()<cr>]],
			["<C-Down>"] = [[<cmd>lua require'tmux'.move_bottom()<cr>]],
			["<C-Up>"] = [[<cmd>lua require'tmux'.move_top()<cr>]],
			["<C-Right>"] = [[<cmd>lua require'tmux'.move_right()<cr>]],

			["<S-Left>"] = [[<cmd>lua require'tmux'.resize_left()<cr>]],
			["<S-Down>"] = [[<cmd>lua require'tmux'.resize_bottom()<cr>]],
			["<S-Up>"] = [[<cmd>lua require'tmux'.resize_top()<cr>]],
			["<S-Right>"] = [[<cmd>lua require'tmux'.resize_right()<cr>]],
		})

		return tmux
	end,
}
