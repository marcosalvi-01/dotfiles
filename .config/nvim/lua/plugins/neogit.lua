return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
	},
	-- fix having the eof line count as a diff when opening diffview from neogit
	config = function(_, opts)
		require("neogit").setup(opts)

		local ok, integration = pcall(require, "neogit.integrations.diffview")
		if not ok or integration._single_file_diffview_patch then
			return
		end

		local original_open = integration.open
		integration._single_file_diffview_patch = true

		integration.open = function(section_name, item_name, open_opts)
			if
				open_opts
				and open_opts.only
				and type(item_name) == "string"
				and (section_name == "unstaged" or section_name == "staged")
			then
				local git = require("neogit.lib.git")
				local diffview_lib = require("diffview.lib")
				local diffview_utils = require("diffview.utils")
				local args = {}

				if open_opts.on_close then
					vim.api.nvim_create_autocmd({ "BufEnter" }, {
						buffer = open_opts.on_close.handle,
						once = true,
						callback = open_opts.on_close.fn,
					})
				end

				if git.repo and git.repo.worktree_root then
					table.insert(args, "-C" .. git.repo.worktree_root)
				end

				if section_name == "staged" then
					table.insert(args, "--cached")
				end

				table.insert(args, "--selected-file=" .. item_name)
				table.insert(args, "--")
				table.insert(args, item_name)

				local view = diffview_lib.diffview_open(diffview_utils.tbl_pack(unpack(args)))
				if view then
					view:open()
				end

				return
			end

			return original_open(section_name, item_name, open_opts)
		end
	end,
	keys = {
		{
			"<leader>n",
			function()
				vim.cmd("Neogit kind=tab")
			end,
			desc = "Open [N]eogit window (Neogit)",
		},
	},
	cmd = {
		"Neogit",
	},
	opts = {
		signs = {
			hunk = { "", "" },
			item = { "", "" },
			section = { "", "" },
		},
		graph_style = "kitty",
		mappings = {
			status = {
				["<c-l>"] = "RefreshBuffer",
			},
		},
	},
}
