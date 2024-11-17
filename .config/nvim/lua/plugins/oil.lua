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
		string.format('git -C %s ls-files --ignored --exclude-standard --others --directory | grep -v "/.*\\/"', dir)

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
	---@module 'oil'
	---@type oil.SetupOpts
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
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
		},
		use_default_keymaps = false,
		view_options = {
			show_hidden = true,
			is_hidden_file = function(name)
				local not_hidden_dotfiles = {
					"../",
					".gitignore",
				}
				if vim.startswith(name, ".") and not vim.tbl_contains(not_hidden_dotfiles, name) then
					return true
				end
				local ignored_files = get_git_ignored_files_in(require("oil").get_current_dir())
				return vim.tbl_contains(ignored_files, name)
			end,
		},
	},
	config = function()
		local detail = false
		require("oil").setup({
			keymaps = {
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
			-- Enable oil-git-status (it needs to be here)
			win_options = {
				signcolumn = "yes:2",
			},
		})

		-- TODO
		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "*.oil",
			callback = function()
				print("Oil changes discarded")
				require("oil").discard_all_changes()
			end,
		})
	end,
}
