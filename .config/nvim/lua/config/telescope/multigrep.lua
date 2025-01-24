local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")
local builtin = require("telescope.builtin")

local M = {}

local live_multigrep

live_multigrep = function(opts)
	opts = opts or {}
	opts.cwd = opts.cwd or vim.loop.cwd()

	local finder = finders.new_async_job({
		command_generator = function(prompt)
			if not prompt or prompt == "" then
				return nil
			end
			local pieces = vim.split(prompt, "  ")
			local args = { "rg" }

			-- Add default ignore pattern for .git directories
			table.insert(args, "--glob=!.git")

			if pieces[1] then
				table.insert(args, "-e")
				table.insert(args, pieces[1])
			end
			if pieces[2] then
				table.insert(args, "-g")
				table.insert(args, pieces[2])
			end

			-- Add grep default arguments
			return vim.tbl_flatten({
				args,
				{
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
				},
			})
		end,
		entry_maker = make_entry.gen_from_vimgrep(opts),
		cwd = opts.cwd,
	})

	pickers
		.new(opts, {
			debounce = 100,
			prompt_title = "Multi Grep",
			finder = finder,
			previewer = conf.grep_previewer(opts),
			sorter = sorters.empty(),
			attach_mappings = function(prompt_bufnr, map)
				-- Map <C-d> to select a directory and rerun grep in it
				map("i", "<C-d>", function()
					-- Close the current picker
					actions.close(prompt_bufnr)

					-- Open a directory picker
					builtin.find_files({
						prompt_title = "Select Directory",
						cwd = opts.cwd,
						-- Only list directories using fd
						find_command = {
							"fd",
							"--type",
							"d",
							"--hidden",
							"--follow",
							"--color=never",
							"--exclude",
							".git",
						},
						attach_mappings = function(dir_prompt_bufnr, dir_map)
							dir_map("i", "<CR>", function()
								-- Get the selected directory
								local selection = action_state.get_selected_entry()
								actions.close(dir_prompt_bufnr)

								if selection and selection.path then
									-- Convert the selected path to an absolute path
									local absolute_path = vim.loop.fs_realpath(selection.path)

									if absolute_path then
										-- Update the cwd to the selected absolute directory
										opts.cwd = absolute_path

										-- Re-run the live_multigrep with the new cwd
										live_multigrep(opts)
									else
										-- Fallback if fs_realpath fails
										opts.cwd = selection.path
										live_multigrep(opts)
									end
								end
							end)
							return true
						end,
					})
				end)

				return true
			end,
		})
		:find()
end

M.open = function(opts)
	live_multigrep(opts)
end

return M
