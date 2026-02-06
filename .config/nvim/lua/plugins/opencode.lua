return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim" },
	},
	keys = {
		{
			"<leader>oa",
			function()
				require("opencode").ask("@this: ", { submit = true })
			end,
			mode = { "n", "x" },
			desc = "Ask opencode...",
		},
		{
			"<leader>oc",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "Execute opencode action...",
		},
		{
			"<leader>ot",
			function()
				require("opencode").toggle()
			end,
			mode = { "n", "x" },
			desc = "Toggle opencode",
		},
		{
			"go",
			function()
				return require("opencode").operator("@this ")
			end,
			mode = { "n", "x" },
			desc = "Add range to opencode",
			expr = true,
		},
		{
			"goo",
			function()
				return require("opencode").operator("@this ") .. "_"
			end,
			mode = "n",
			desc = "Add line to opencode",
			expr = true,
		},
	},
	config = function()
		---@class OpencodeTmuxProvider : opencode.Provider
		---@field session? string
		---@field window string
		---@field tmux fun(self: OpencodeTmuxProvider, args: string[]): string
		---@field trim fun(self: OpencodeTmuxProvider, value: string): string
		---@field current_session fun(self: OpencodeTmuxProvider): string
		---@field session_name fun(self: OpencodeTmuxProvider): string
		---@field target fun(self: OpencodeTmuxProvider): string
		---@field window_exists fun(self: OpencodeTmuxProvider): boolean
		---@field create_window fun(self: OpencodeTmuxProvider)
		---@field focus fun(self: OpencodeTmuxProvider)

		---@type OpencodeTmuxProvider
		local tmux_provider = {
			toggle = function(self)
				self:start()
				self:focus()
			end,
			start = function(self)
				if self:window_exists() then
					return
				end
				self:create_window()
			end,
			stop = function(self)
				if not self:window_exists() then
					return
				end
				self:tmux({ "kill-window", "-t", self:target() })
			end,
			session = nil,
			window = "opencode",
			tmux = function(_, args)
				local cmd = { "tmux" }
				vim.list_extend(cmd, args)
				return vim.fn.system(cmd)
			end,
			trim = function(_, value)
				return (value:gsub("^%s+", ""):gsub("%s+$", ""))
			end,
			current_session = function(self)
				return self:trim(self:tmux({ "display-message", "-p", "#S" }))
			end,
			session_name = function(self)
				return self.session or self:current_session()
			end,
			target = function(self)
				return string.format("%s:%s", self:session_name(), self.window)
			end,
			window_exists = function(self)
				local output = self:tmux({ "list-windows", "-t", self:session_name(), "-F", "#W" })
				for name in output:gmatch("[^\n]+") do
					if self:trim(name) == self.window then
						return true
					end
				end
				return false
			end,
			create_window = function(self)
				local port = (vim.g.opencode_opts and vim.g.opencode_opts.server and vim.g.opencode_opts.server.port) or
				3010
				local command = string.format("opencode --port %d", port)
				self:tmux({ "new-window", "-t", self:session_name(), "-n", self.window, command })
			end,
			focus = function(self)
				self:tmux({ "select-window", "-t", self:target() })
			end,
		}

		---@type opencode.Opts
		vim.g.opencode_opts = {
			provider = {
				enabled = "tmux",
				tmux = {
					-- ...
				}
			}
		}
		-- Required for `opts.events.reload`.
		vim.o.autoread = true
	end,
}
