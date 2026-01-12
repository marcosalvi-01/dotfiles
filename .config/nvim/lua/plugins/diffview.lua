local function get_default_branch_name()
	local res = vim.system({ "git", "rev-parse", "--verify", "main" }, { capture_output = true }):wait()
	return res.code == 0 and "main" or "master"
end

return {
	"sindrets/diffview.nvim",
	opts = {
		show_help_hints = false,
		enhanced_diff_hl = false,
		hooks = {
			diff_buf_win_enter = function()
				vim.opt_local.foldenable = false
				vim.opt_local.wrap = false
			end,
		},
		keymaps = {
			view = {
				{
					"n",
					"q",
					function()
						vim.cmd("tabc")
					end,
					{ desc = "Close the diff" },
				},
				{
					"n",
					"<esc>",
					function()
						vim.cmd("tabc")
					end,
					{ desc = "Close the diff" },
				},
				{
					"n",
					"<leader>hp",
					function()
						vim.cmd("norm! [czz")
					end,
					{ desc = "Previous hunk (Diffview)" },
				},
				{
					"n",
					"<leader>hn",
					function()
						vim.cmd("norm! ]czz")
					end,
					{ desc = "Next hunk (Diffview)" },
				},
				{
					"n",
					"<leader>e",
					function()
						require("diffview.actions").toggle_files()
					end,
					{ desc = "Toggle the file panel" },
				},
			},
			file_panel = {
				{
					"n",
					"q",
					function()
						vim.cmd("tabc")
					end,
					{ desc = "Close the panel" },
				},
				{
					"n",
					"<esc>",
					function()
						vim.cmd("tabc")
					end,
					{ desc = "Close the diff" },
				},
				{
					"n",
					"<leader>e",
					function()
						require("diffview.actions").toggle_files()
					end,
					{ desc = "Toggle the file panel" },
				},
				{
					"n",
					"t",
					function()
						require("diffview.actions").listing_style()
					end,
					{ desc = "Toggle file panel listing style" },
				},
				{
					"n",
					"<cr>",
					function()
						require("diffview.actions").focus_entry()
					end,
					{ desc = "Open and focus the diff for the selected entry." },
				},
			},
			file_history_panel = {
				{
					"n",
					"q",
					function()
						vim.cmd("tabc")
					end,
					{ desc = "Close the panel" },
				},
				{
					"n",
					"<esc>",
					function()
						vim.cmd("tabc")
					end,
					{ desc = "Close the diff" },
				},
				{
					"n",
					"<leader>e",
					function()
						require("diffview.actions").toggle_files()
					end,
					{ desc = "Toggle the file panel" },
				},
			},
		},
		file_panel = {
			listing_style = "list", -- One of 'list' or 'tree'
			win_config = {
				position = "left",
				width = 30,
			},
		},
		file_history_panel = {
			win_config = {
				position = "bottom",
				height = 8,
			},
		},
	},
	keys = {
		{
			"<leader>hd",
			function()
				local pos = vim.api.nvim_win_get_cursor(0)
				local line = pos[1]
				local col = pos[2]
				vim.cmd("DiffviewOpen")
				vim.cmd("DiffviewToggleFiles")
				vim.cmd("sleep 100m")
				vim.api.nvim_win_set_cursor(0, { line, col })
			end,
			desc = "Git Diff this file [Diffview]",
		},
		{
			"<leader>hl",
			mode = "v",
			function()
				vim.cmd("'<,'>DiffviewFileHistory --follow")
			end,
			desc = "Visual selection history [Diffview]",
		},
		{
			"<leader>hl",
			function()
				vim.cmd(". DiffviewFileHistory --follow")
			end,
			desc = "Line history [Diffview]",
		},
		{
			"<leader>hb",
			function()
				vim.cmd("DiffviewFileHistory")
			end,
			desc = "Branch history [Diffview]",
		},
		{
			"<leader>hf",
			function()
				vim.cmd("DiffviewFileHistory --follow %")
			end,
			desc = "File history [Diffview]",
		},
		{
			"<leader>hm",
			function()
				vim.cmd("DiffviewOpen " .. get_default_branch_name())
			end,
			desc = "Diff against master [Diffview]",
		},
		{
			"<leader>hM",
			function()
				vim.cmd("DiffviewOpen HEAD..origin/" .. get_default_branch_name())
			end,
			desc = "Diff against origin/master [Diffview]",
		},
	},
}
