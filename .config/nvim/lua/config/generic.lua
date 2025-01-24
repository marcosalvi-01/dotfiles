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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		vim.bo.commentstring = "-- %s"
	end,
})
