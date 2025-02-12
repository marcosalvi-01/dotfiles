function printTableOneLine(tbl)
	local result = {}
	for key, value in pairs(tbl) do
		local formattedValue
		if type(value) == "table" then
			formattedValue = "{...}" -- Indicating nested table
		elseif type(value) == "string" then
			formattedValue = string.format("%q", value) -- Quote strings
		else
			formattedValue = tostring(value)
		end
		table.insert(result, tostring(key) .. "=" .. formattedValue)
	end
	print("{" .. table.concat(result, ", ") .. "}")
end
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			force = true,
		},
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
		},
		quickfile = { enabled = true },
		picker = {
			sources = {
				dirs = {
					finder = "proc",
					cmd = "fd",
					args = { "--type", "d", "--hidden", "--exclude", ".git" },
					transform = function(item)
						item.file = item.text
						item.dir = true
					end,
				},
				multigrep = {
					finder = "grep",
					regex = true,
					format = "file",
					show_empty = true,
					live = true,
					supports_live = true,
					hidden = true,
					win = {
						input = {
							keys = {
								["<C-d>"] = { "refine_dir", mode = "i" },
							},
						},
					},
					actions = {
						-- custom action to grep only inside a specific dir
						refine_dir = function(p)
							p:close()
							Snacks.picker({
								finder = "proc",
								cmd = "fd",
								args = { "--type", "d", "--hidden", "--follow", "--color=never", "--exclude", ".git" },
								transform = function(item)
									item.file = item.text
									item.dir = true
								end,
								confirm = function(picker, item)
									picker:close()
									if item then
										Snacks.picker.multigrep({
											cwd = vim.fs.joinpath(vim.fn.getcwd(), item.file),
										})
									end
								end,
							})
						end,
					},
				},
			},
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
						title = "{title}",
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
						["<C-right>"] = { "focus_preview", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },
						["<C-u>"] = { "clear_input", mode = "i" },
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
					b = {
						minipairs_disable = true,
					},
				},
				actions = {
					clear_input = function(p)
						vim.api.nvim_win_call(p.input.win.win, function()
							vim.cmd('normal! "_cc')
						end)
					end,
				},
				preview = {
					keys = {
						["<C-left>"] = "focus_input",
						["<C-p>"] = "toggle_preview",
					},
				},
			},
			actions = {
				clear_input = function(p)
					vim.api.nvim_win_call(p.input.win.win, function()
						vim.cmd('normal! "_cc')
					end)
				end,
			},
		},
	},
	keys = {
		{
			"<leader>sf",
			function()
				require("snacks").picker.files({
					hidden = true,
				})
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
			end,
			desc = "Find Config File",
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
						reverse = false,
						layout = {
							row = 1,
							width = 0.4,
							min_width = 80,
							height = 0.4,
							border = "none",
							box = "vertical",
							title = "{title}",
							title_pos = "center",
							{
								box = "vertical",
								border = "rounded",
								{
									win = "input",
									height = 1,
									border = "bottom",
								},
								{ win = "list", border = "none" },
								{ win = "preview", title = "{preview}", border = "none" },
							},
						},
					},
				})
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sg",
			function()
				-- Snacks.picker.sources.multigrep = {
				-- 	finder = "grep",
				-- 	hidden = true,
				-- 	-- win = {
				-- 	-- 	input = {
				-- 	-- 		keys = {
				-- 	-- 			["<C-d>"] = { "refine_dir", mode = "i" },
				-- 	-- 		},
				-- 	-- 	},
				-- 	-- },
				-- 	actions = {
				-- 		refine_dir = function(p)
				-- 			p:close()
				-- 			Snacks.picker({
				-- 				finder = "proc",
				-- 				cmd = "fd",
				-- 				args = { "--type", "d", "--hidden", "--follow", "--color=never", "--exclude", ".git" },
				-- 				transform = function(item)
				-- 					item.file = item.text
				-- 					item.dir = true
				-- 				end,
				-- 				confirm = function(picker, item)
				-- 					picker:close()
				-- 					if item then
				-- 						Snacks.picker.multigrep()
				-- 					end
				-- 				end,
				-- 			})
				-- 		end,
				-- 	},
				-- }
				Snacks.picker.multigrep()
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
				Snacks.picker.dirs()
			end,
			{ desc = "Search subdirectories by name" },
		},
		{
			"<leader>se",
			function()
				Snacks.picker.explorer({
					hidden = true,
					auto_close = true,
					layout = {
						reverse = false,
						layout = {
							row = 1,
							width = 0.2,
							min_width = 60,
							height = 1,
							border = "none",
							box = "vertical",
							-- title = "{title}",
							-- title_pos = "center",
							position = "left",
							{
								box = "vertical",
								{
									win = "input",
									height = 1,
									border = "hpad",
								},
								{ win = "list", border = "none" },
							},
						},
					},
					win = {
						input = {
							keys = {
								["<C-down>"] = { "focus_list", mode = "i" },
							},
						},
						list = {
							keys = {
								["<BS>"] = "explorer_up",
								["<right>"] = "confirm",
								["<left>"] = "explorer_close", -- close directory
								["a"] = "explorer_add",
								["d"] = "explorer_del",
								["r"] = "explorer_rename",
								["c"] = "explorer_copy",
								["m"] = "explorer_move",
								["o"] = "explorer_open", -- open with system application
								["p"] = "toggle_preview",
								["y"] = "explorer_yank",
								["u"] = "explorer_update",
								["<c-c>"] = "tcd",
								["."] = "explorer_focus",
								["I"] = "toggle_ignored",
								["H"] = "toggle_hidden",
								["Z"] = "explorer_close_all",
								["]g"] = "explorer_git_next",
								["[g"] = "explorer_git_prev",
								["]d"] = "explorer_diagnostic_next",
								["[d"] = "explorer_diagnostic_prev",
								["]w"] = "explorer_warn_next",
								["[w"] = "explorer_warn_prev",
								["]e"] = "explorer_error_next",
								["[e"] = "explorer_error_prev",
								["<C-up>"] = "focus_input",
							},
						},
					},
				})
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
