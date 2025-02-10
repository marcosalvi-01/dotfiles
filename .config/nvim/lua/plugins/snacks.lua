return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
		},
		quickfile = { enabled = true },
		picker = {
			prompt = " ",
			ui_select = true,
			layout = {
				reverse = true,
				layout = {
					box = "horizontal",
					width = 0.8,
					min_width = 120,
					height = 0.8,
					{
						box = "horizontal",
						border = "rounded",
						title = "{title} {live}",
						{
							box = "vertical",
							{ win = "list", border = "none" },
							{ win = "input", height = 1, border = "top" },
						},
						{ win = "preview", title = "{preview}", border = "left", width = 0.5 },
					},
				},
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<C-s>"] = { "edit_vsplit", mode = { "i", "n" }, desc = "Vertical Split" },
						["<C-p>"] = { "toggle_preview", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },
						["<C-H>"] = {
							function()
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<C-w>", true, true, true),
									"i",
									false
								)
							end,
							mode = { "i" },
						},
					},
				},
			},
		},
	},
	keys = {
		{
			"<leader>sf",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>sn",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"\\",
			function()
				Snacks.picker.lines({
					layout = {
						layout = {
							backdrop = false,
							row = 1,
							width = 0.4,
							min_width = 80,
							height = 0.4,
							border = "rounded",
							box = "vertical",
							title = "{title} {live} {flags}",
							title_pos = "center",
							{
								win = "input",
								height = 1,
								border = "bottom",
							},
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", border = "none" },
						},
					},
				})
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep({
					hidden = true,
				})
			end,
			desc = "Grep",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word({
					hidden = true,
				})
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>sH",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Highlights",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>sM",
			function()
				Snacks.picker.man()
			end,
			desc = "Man Pages",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>sr",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>su",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo History",
		},
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>sS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
		{
			"<leader>si",
			function()
				Snacks.picker.files({
					args = { "-t", "d" },
					cwd = vim.fn.getcwd(),
				})
			end,
			{ desc = "Search subdirectories by name" },
		},
		{
			"<leader>se",
			function()
				Snacks.picker.explorer()
			end,
			{ desc = "Open explorer" },
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.spelling()
			end,
			{ desc = "Spelling" },
		},
	},
}
