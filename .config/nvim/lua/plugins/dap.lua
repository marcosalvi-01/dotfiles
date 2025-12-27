return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"igorlfs/nvim-dap-view",
		},
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint [DAP]",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue [DAP]",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over [DAP]",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into [DAP]",
			},
			{
				"<leader>dr",
				function()
					require("dap").restart()
				end,
				desc = "Restart [DAP]",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate [DAP]",
			},
			{
				"<leader>du",
				function()
					require("dap-view").toggle()
				end,
				desc = "Toggle DAP View [DAP]",
			},
			{
				"<leader>dw",
				mode = { "n", "v" },
				function()
					vim.cmd("DapViewWatch")
				end,
				desc = "Add variable to watchlist [DAP]",
			},
		},
		config = function()
			local dap = require("dap")
			local dapview = require("dap-view")

			-- Setup dap-view
			dapview.setup({
				auto_toggle = true,
				winbar = {
					controls = {
						enabled = true,
					},
					sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
				},
				windows = {
					position = function()
						local width = vim.o.columns
						local threshold = 10 -- adjust this to your preference
						return width >= threshold and "right" or "below"
					end,
					terminal = {
						hide = { "delve" },
					},
				},
			})

			-- Define signs for breakpoints and stopped line
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
			vim.fn.sign_define(
				"DapBreakpointCondition",
				{ text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" }
			)
			vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticError", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })

			-- Auto-open/close view on debug events
			dap.listeners.after.event_initialized["dapview_config"] = function()
				dapview.open()
			end
			dap.listeners.before.event_terminated["dapview_config"] = function()
				dapview.close()
			end
			dap.listeners.before.event_exited["dapview_config"] = function()
				dapview.close()
			end

			-- Go adapter with conditional remote attach
			dap.adapters.go = function(callback, config)
				if config.mode == "remote" and config.request == "attach" then
					callback({
						type = "server",
						host = config.host or "127.0.0.1",
						port = config.port or 2345,
					})
				else
					callback({
						type = "server",
						port = "${port}",
						executable = {
							command = "dlv",
							args = { "dap", "-l", "127.0.0.1:${port}" },
						},
					})
				end
			end

			dap.configurations.go = {
				{
					type = "go",
					name = "Attach to running delve (TUI)",
					request = "attach",
					mode = "remote",
					host = "127.0.0.1",
					port = 2345,
				},
			}
		end,
	},
}
