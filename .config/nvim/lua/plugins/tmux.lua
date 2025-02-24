return {
	"aserowy/tmux.nvim",
	opts = {
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
	},
	keys = {
		{
			"<S-Left>",
			function()
				require("tmux").resize_left()
			end,
			desc = "Tmux resize left",
		},
		{
			"<S-Right>",
			function()
				require("tmux").resize_right()
			end,
			desc = "Tmux resize right",
		},
		{
			"<S-Down>",
			function()
				require("tmux").resize_bottom()
			end,
			desc = "Tmux resize down",
		},
		{
			"<S-Up>",
			function()
				require("tmux").resize_top()
			end,
			desc = "Tmux resize top",
		},
		{
			"<C-Left>",
			function()
				require("tmux").move_left()
			end,
			desc = "Tmux move left",
		},
		{
			"<C-Right>",
			function()
				require("tmux").move_right()
			end,
			desc = "Tmux move right",
		},
		{
			"<C-Up>",
			function()
				require("tmux").move_top()
			end,
			desc = "Tmux move up",
		},
		{
			"<C-Down>",
			function()
				require("tmux").move_bottom()
			end,
			desc = "Tmux move down",
		},
	},
}
