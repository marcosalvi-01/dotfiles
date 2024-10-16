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
