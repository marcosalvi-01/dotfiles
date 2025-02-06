-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Add borders to diagnostic windows
vim.diagnostic.config({
	float = { border = "rounded" },
})

-- Add a new file type .cwl
vim.filetype.add({ extension = { cwl = "cwl" } })
-- Register cwl files as yaml for syntax highlighting
vim.treesitter.language.register("yaml", { "yaml", "cwl" })

-- Configure .http files
vim.filetype.add({ extension = { http = "http" } })
vim.treesitter.language.register("http", { "http", "http" })

vim.opt.pumblend = 0

-- Set custom indentation rules for .cwl files
vim.api.nvim_create_autocmd({ "FileType" }, {
	desc = "Change indentation rules for .cwl files",
	group = vim.api.nvim_create_augroup("cwl-indentation", { clear = true }),
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
	end,
	pattern = { "cwl" },
})

-- for hyprland conf
vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

-- change icons for diagnostic sings (on the left of the line number)
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
-- disable diagnostic signs on the left of the line number
vim.diagnostic.config({
	signs = false,
})

-- autocmd to update the macro label in the lualine
vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		-- This is going to seem really weird!
		-- Instead of just calling refresh we need to wait a moment because of the nature of
		-- `vim.fn.reg_recording`. If we tell lualine to refresh right now it actually will
		-- still show a recording occuring because `vim.fn.reg_recording` hasn't emptied yet.
		-- So what we need to do is wait a tiny amount of time (in this instance 50 ms) to
		-- ensure `vim.fn.reg_recording` is purged before asking lualine to refresh.
		local timer = vim.loop.new_timer()
		timer:start(
			50,
			0,
			vim.schedule_wrap(function()
				require("lualine").refresh({
					place = { "statusline" },
				})
			end)
		)
	end,
})
