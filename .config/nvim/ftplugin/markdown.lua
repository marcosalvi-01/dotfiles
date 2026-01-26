vim.opt.wrap = true
vim.opt.linebreak = true

vim.keymap.set({ "n", "i" }, "<C-p>", function()
	vim.cmd("RenderMarkdown buf_toggle")
end, { desc = "Toggles markview previews globally" })
