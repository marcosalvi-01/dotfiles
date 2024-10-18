return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	-- Optional dependencies
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
	config = function()
		function _G.get_oil_winbar()
			local dir = require("oil").get_current_dir()
			if dir then
				return vim.fn.fnamemodify(dir, ":~")
			else
				-- If there is no current directory (e.g. over ssh), just show the buffer name
				return vim.api.nvim_buf_get_name(0)
			end
		end

		local detail = false
		require("oil").setup({
			keymaps = {
				["gd"] = {
					desc = "Toggle file detail view (Oil.nvim)",
					callback = function()
						detail = not detail
						if detail then
							require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
			},
			view_options = {
				show_hidden = true,
			},
			win_options = {
				winbar = "%!v:lua.get_oil_winbar()",
			},
		})

		vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "Open file bowser (Oil.nvim)" })
	end,
}
