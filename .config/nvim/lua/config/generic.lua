-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ higroup = "HighlightedyankRegion" })
	end,
})

-- Add borders to diagnostic windows
vim.diagnostic.config({
	float = { border = "rounded" },
})

-- Configure .http files
vim.filetype.add({ extension = { http = "http" } })
vim.treesitter.language.register("http", { "http", "http" })

-- Autocmd to disable diagnostics for .env files
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { ".env", "*.env" },
	group = vim.api.nvim_create_augroup("__env", { clear = true }),
	callback = function()
		vim.diagnostic.enable(false)
	end,
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

-- LSP folding setup
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.server_capabilities.foldingRangeProvider then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win].foldmethod = "expr"
			vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end
	end,
})
vim.api.nvim_create_autocmd("LspDetach", { command = "setl foldexpr<" })

vim.filetype.add({ extension = { templ = "templ" } })

if vim.fn.has("nvim-0.12") == 1 then
	vim.o.diffopt = "internal,filler,closeoff,inline:word,linematch:40"
elseif vim.fn.has("nvim-0.11") == 1 then
	vim.o.diffopt = "internal,filler,closeoff,linematch:40"
end

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
	command = "wincmd =",
})

-- syntax highlighting for dotenv files
vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
	pattern = { ".env", ".env.*" },
	callback = function()
		vim.bo.filetype = "dosini"
	end,
})
