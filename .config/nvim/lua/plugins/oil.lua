-- Global function to get the git ignored files for a dir
local function get_git_ignored_files_in(dir)
	local found = vim.fs.find(".git", {
		upward = true,
		path = dir,
	})
	if #found == 0 then
		return {}
	end

	local cmd =
		string.format('git -C %s ls-files --ignored --exclude-standard --others --directory | grep -v "/*.*/"', dir)

	local handle = io.popen(cmd)
	if handle == nil then
		return
	end

	local ignored_files = {}
	for line in handle:lines("*l") do
		line = line:gsub("/$", "")
		table.insert(ignored_files, line)
	end
	handle:close()

	return ignored_files
end

return {
	"stevearc/oil.nvim",
	config = function()
		local detail = false
		require("oil").setup({
			preview_win = {
				preview_method = "load",
			},
			watch_for_changes = true,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<Tab>"] = "actions.select",
				["<C-s>"] = {
					"actions.select",
					opts = { vertical = true },
					desc = "Open the entry in a vertical split",
				},
				["<C-h>"] = {
					"actions.select",
					opts = { horizontal = true },
					desc = "Open the entry in a horizontal split",
				},
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				-- ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory", mode = "n" },
				["gs"] = "actions.change_sort",
				["g."] = "actions.toggle_hidden",
				-- ["g\\"] = "actions.toggle_trash",
				["gd"] = {
					desc = "Toggle file detail view (Oil)",
					callback = function()
						detail = not detail
						if detail then
							require("oil").set_columns({ "permissions", "size", "mtime", "icon" })
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
			},
			use_default_keymaps = false,
			-- 2. is_always_hidden: Parent directory entry (..) is always hidden
			-- 3. is_hidden_file: Determines which files are considered "hidden"
			--    - In git repos: Files are hidden if they are git-ignored OR in the explicit ignore list
			--    - Outside git repos: Files are hidden if they start with a dot (.)
			view_options = {
				show_hidden = false,
				is_always_hidden = function(name, bufnr)
					return name == ".."
				end,
				is_hidden_file = function(name)
					-- Two possibilities:
					-- - git repo: a file is hidden only if it is ignored or it is in the "ignored" table
					-- - non git repo: a file is hidden only if it starts with "."
					local ignored_files = get_git_ignored_files_in(vim.fn.getcwd())
					if ignored_files == {} then
						return vim.startswith(name, ".")
					end

					local ignored = {
						".git",
						"../",
					}

					return vim.tbl_contains(ignored_files, name) or vim.tbl_contains(ignored, name)
				end,
			},
			-- Enable oil-git-status
			win_options = {
				signcolumn = "yes:1",
			},
		})

		-- Discard all changes when leaving the oil buffer
		vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
			pattern = { "oil://*" },
			callback = function()
				require("oil").discard_all_changes()
				-- vim.notify("Discarded all unsaved oil changes")
			end,
		})
	end,
}
