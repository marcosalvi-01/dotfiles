-- Add a new file type .cwl
vim.filetype.add({ extension = { cwl = "cwl" } })
-- Register cwl files as yaml for syntax highlighting
vim.treesitter.language.register("yaml", { "yaml", "cwl" })

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

vim.lsp.enable("cwl")
