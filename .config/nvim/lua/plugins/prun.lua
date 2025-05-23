return {
	-- dir = "~/prun/",
	"marcosalvi-01/prun",
	keys = {
		{
			"<leader>m",
			function()
				require("prun").manage()
			end,
			desc = "Expand quickfix context",
		},
		{
			"<F1>",
			function()
				require("prun").run(1)
			end,
			desc = "Run command 1 [prun]",
		},
		{
			"<F2>",
			function()
				require("prun").run(2)
			end,
			desc = "Run command 2 [prun]",
		},
		{
			"<F3>",
			function()
				require("prun").run(3)
			end,
			desc = "Run command 3 [prun]",
		},
	},
	opts = {
		tmux_pane = 1,
		-- [sh] means that the command will be run in a temporary shell, not in the tux window
		default_pre = "[sh] tmux-shell-popup -b rounded -w 70% -h 70% -T '%s' %s %w 0",
	},
}
