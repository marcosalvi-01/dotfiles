return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		image = {},
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
		},
		quickfile = { enabled = true },
		picker = {
			matcher = {
				frecency = true,
			},
			-- needed for the custom refine_dir action
			auto_close = false,
			layouts = {
				main_preview = {
					preview = "main",
					reverse = false,
					layout = {
						row = 0,
						width = 0.4,
						min_width = 80,
						height = 0.4,
						max_height = 10,
						title = "{title}",
						title_pos = "center",
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
			sources = {
				-- custom picker for dirs
				dirs = {
					finder = "proc",
					cmd = "fd",
					args = { "--type", "d", "--hidden", "--exclude", ".git" },
					transform = function(item)
						item.file = item.text
						item.dir = true
					end,
				},
				select = {
					layout = {
						reverse = false,
						layout = {
							row = 1,
							width = 0.4,
							min_width = 80,
							height = 0.4,
							border = "rounded",
							box = "vertical",
							title = "{title}",
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
					min_height = 10,
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
						["<C-i>"] = { "toggle_ignored", mode = "i" },
						-- ["<C-h>"] = { "toggle_hidden", mode = "i" },
						-- ctrl + backspace
						["<C-H>"] = { "delete_word", mode = { "i" } },
						["<C-d>"] = { "refine_dir", mode = "i" },
						["<BS>"] = { "backspace", mode = "i" },
					},
					b = {
						minipairs_disable = true,
					},
				},
				preview = {
					keys = {
						["<C-left>"] = "focus_input",
						["<C-p>"] = "toggle_preview",
					},
				},
			},
			actions = {
				-- close the popup if the filter is empty on backspace
				backspace = function(p)
					local filter = p:filter()
					if filter.pattern == "" and filter.search == "" then
						p:close()
					else
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<bs>", true, true, true), "n", false)
					end
				end,
				delete_word = function(p)
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>", true, true, true), "i", false)
				end,
				clear_input = function(p)
					vim.api.nvim_win_call(p.input.win.win, function()
						vim.cmd('normal! "_cc')
					end)
				end,
				refine_dir = function(p)
					p:toggle()
					local newDir = nil
					Snacks.picker.dirs({
						confirm = function(picker, item)
							newDir = vim.fs.joinpath(vim.fn.getcwd(), item.file)
							picker:close()
							if item then
								p:set_cwd(newDir)
								p:find()
								p:focus()
								-- TODO: for some reason this does not put the cursor at the end of the line!
								vim.api.nvim_win_call(p.input.win.win, function()
									vim.cmd("normal A")
								end)
							end
						end,
						on_close = function()
							if not newDir then
								p:close()
							end
						end,
						title = "Refine Dir",
					})
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
			desc = "Snacks [S]earch [F]iles",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
			end,
			desc = "Snacks [S]earch [P]lugins",
		},
		{
			"<leader>sn",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Snacks [S]earch [C]onfig",
		},
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches()
			end,
			desc = "Snacks [G]it [B]ranches",
		},
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Snacks [G]it [L]og",
		},
		{
			"\\",
			function()
				Snacks.picker.lines({
					layout = "main_preview",
				})
			end,
			desc = "Snacks Search Lines In Buffer",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep({
					hidden = true,
				})
			end,
			desc = "Snacks [S]earch [G]rep",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.lines({
					search = function(picker)
						return picker:word()
					end,
					finder = "grep",
					regex = false,
					format = "file",
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [W]ord",
			mode = "n",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [D]iagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch Buffer [D]iagnostics",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "Snacks [S]earch [H]elp",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Snacks [S]earch [K]eymaps",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Snacks [S]earch [M]arks",
		},
		{
			"<leader>sM",
			function()
				Snacks.picker.man()
			end,
			desc = "Snacks [S]earch [M]an Pages",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [Q]uickfix",
		},
		{
			"<leader>sr",
			function()
				Snacks.picker.resume()
			end,
			desc = "Snacks [S]earch [R]esume",
		},
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [G]oto [D]efinition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_type_definitions({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [G]oto Type [D]efinition",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references({
					layout = "main_preview",
				})
			end,
			nowait = true,
			desc = "Snacks [G]oto [R]eferences",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [G]oto [I]mplementation",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.lsp_symbols({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [L]sp symbols",
		},
		{
			"<leader>sL",
			function()
				Snacks.picker.lsp_workspace_symbols({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch Workspace [L]sp symbols",
		},
		{
			"<leader>si",
			function()
				Snacks.picker.dirs()
			end,
			desc = "Snacks [S]earch D[I]rectories",
		},
		{
			"<leader>se",
			function()
				Snacks.picker.explorer({
					hidden = true,
					auto_close = true,
					on_show = function(picker)
						picker:action("toggle_preview")
					end,
					layout = {
						preview = "main",
						reverse = false,
						layout = {
							row = 1,
							width = 0.2,
							min_width = 60,
							height = 1,
							border = "rounded",
							box = "vertical",
							position = "left",
							title = "{title}",
							{
								win = "input",
								height = 1,
								border = "hpad",
							},
							{ win = "list", border = "top" },
							{ win = "preview", title = "{preview}", border = "none" },
						},
					},
					win = {
						input = {
							keys = {
								["<C-down>"] = { "focus_list", mode = "i" },
								["<C-right>"] = { "confirm", mode = "i" },
								["<C-p>"] = { "toggle_preview", mode = "i" },
							},
						},
						list = {
							keys = {
								["<BS>"] = "explorer_up",
								["<right>"] = "confirm",
								["<c-right>"] = "confirm",
								["<left>"] = "explorer_close",
								["a"] = "explorer_add",
								["d"] = "explorer_del",
								["r"] = "explorer_rename",
								["c"] = "explorer_copy",
								["m"] = "explorer_move",
								["o"] = "explorer_open",
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
								["<C-p>"] = "toggle_preview",
							},
						},
					},
				})
			end,
			desc = "Snacks [S]earch [E]xplorer",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.spelling()
			end,
			desc = "Snacks [S]earch [S]pelling",
		},
		{
			"<leader>hg",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Snacks [H]i[G]hlights",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Snacks [S]earch open [B]uffers",
		},
	},
}
