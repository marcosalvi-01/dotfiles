local layout_strategies = require("telescope.pickers.layout_strategies")
local telescope = require("telescope")
local telescope_actions = require("telescope.actions")
local telescope_actions_layout = require("telescope.actions.layout")
local telescope_actions_state = require("telescope.actions.state")
local telescope_themes = require("telescope.themes")
local telescope_builtin = require("telescope.builtin")

return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
	},
	config = function()
		-- horizontal_fused layout strategy
		layout_strategies.horizontal_fused = function(picker, max_columns, max_lines, layout_config)
			local layout = layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)
			layout.results.title = layout.prompt.title
			layout.results.height = layout.results.height + 1
			if layout.preview ~= nil and layout.preview ~= false and layout.preview ~= true then
				layout.preview.title = ""
				layout.preview.borderchars = { "─", "│", "─", "│", "┬", "╮", "╯", "┴" }
				layout.results.width = layout.results.width + 1
				layout.prompt.width = layout.prompt.width + 1
			else
				layout.results.borderchars = { "─", "│", "─", "│", "╭", "╮", "│", "│" }
				layout.prompt.borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
			end
			return layout
		end
		telescope.setup({
			defaults = {
				selection_caret = " ",
				prompt_prefix = " ",
				preview = {
					hide_on_startup = true, -- hide previewer when picker starts
				},
				layout_strategy = "horizontal_fused",
				mappings = {
					i = {
						-- Open in vertical slit
						["<c-s>"] = "select_vertical",
						-- Clear the prompt
						["<c-u>"] = false,
						-- Close the telescope window with <BS> if the prompt is empty
						["<bs>"] = function(bufnr)
							local prompt = telescope_actions_state.get_current_line()
							if prompt == "" then
								telescope_actions.close(bufnr)
							else
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<bs>", true, true, true),
									"n",
									false
								)
							end
						end,
						["<C-H>"] = function()
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>", true, true, true), "i", false)
						end,
						["<c-enter>"] = "to_fuzzy_refine",
						["<Esc>"] = telescope_actions.close,
						["<C-p>"] = telescope_actions_layout.toggle_preview,
						["<PageUp>"] = telescope_actions.preview_scrolling_up,
						["<PageDown>"] = telescope_actions.preview_scrolling_down,
					},
				},
			},
			extensions = {
				-- set telescope as the default picker in nvim
				["ui-select"] = {
					telescope_themes.get_dropdown(),
				},
				fzf = {},
				file_browser = { hijack_netrw = true },
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")

		-- See `:help telescope.builtin`
		vim.keymap.set("n", "<leader>sh", telescope_builtin.help_tags, { desc = "[S]earch [H]elp (Telescope)" })
		vim.keymap.set("n", "<leader>sk", telescope_builtin.keymaps, { desc = "[S]earch [K]eymaps (Telescope)" })
		vim.keymap.set("n", "<leader>gf", telescope_builtin.git_files, { desc = "Search [G]it [F]iles (Telescope)" })
		vim.keymap.set("n", "<leader>sR", telescope_builtin.resume, { desc = "[S]earch [R]esume (Telescope)" })
		vim.keymap.set("n", "<leader>sr", telescope_builtin.registers, { desc = "[S]earch [R]egisters (Telescope)" })
		vim.keymap.set("n", "<leader>sm", telescope_builtin.man_pages, { desc = "[S] Find [M]an pages (Telescope)" })
		vim.keymap.set("n", "*", function()
			local word = vim.fn.expand("<cword>")
			telescope_builtin.current_buffer_fuzzy_find({
				default_text = "'" .. word,
				prompt_title = "Search Current Word: " .. word,
				attach_mappings = function(prompt_bufnr, map)
					map("i", "<Esc>", function()
						telescope_actions.close(prompt_bufnr)
					end)
					map("i", "<CR>", function()
						vim.cmd("/" .. word)
						telescope_actions.select_default(prompt_bufnr)
					end)

					return true
				end,
			})
		end, { desc = "[*] Search current word (Exact)" })
		vim.keymap.set(
			"n",
			"<leader>sg",
			require("config.telescope.multigrep").open,
			{ desc = "[S]earch by [G]rep (Telescope)" }
		)
		vim.keymap.set(
			"n",
			"<leader>sd",
			telescope_builtin.diagnostics,
			{ desc = "[S]earch [D]iagnostics (Telescope)" }
		)
		vim.keymap.set("n", "<leader>si", function()
			require("telescope.builtin").find_files({
				prompt_title = "Search Directories",
				find_command = { "fd", "--type", "d", "--hidden", "--follow", "--color=never", "--exclude", ".git" },
			})
		end, { desc = "[S]earch [D]irectories Recursively (Telescope)" })
		vim.keymap.set(
			"n",
			"<leader>sb",
			telescope_builtin.buffers,
			{ desc = "[S]earch existing [B]uffers (Telescope)" }
		)
		vim.keymap.set(
			"n",
			"\\",
			telescope_builtin.current_buffer_fuzzy_find,
			{ desc = "[\\] Fuzzily search in current buffer (Telescope)" }
		)

		vim.keymap.set("n", "<leader>sf", function()
			require("telescope.builtin").find_files({ find_command = { "rg", "--files", "--hidden", "-g", "!.git" } })
		end, { desc = "[S]earch [F]iles (Telescope)" })

		vim.keymap.set("n", "<leader>sn", function()
			telescope_builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files (Telescope)" })

		vim.keymap.set("n", "<leader>sp", function()
			---@diagnostic disable-next-line: param-type-mismatch
			telescope_builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
		end, { desc = "[S]earch [P]lugin files (Telescope)" })
	end,
}
