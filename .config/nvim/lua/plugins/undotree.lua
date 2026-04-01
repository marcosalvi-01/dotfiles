vim.cmd("packadd nvim.undotree")

vim.keymap.set("n", "<leader>u", function()
	require("undotree").open({
		command = "topleft 40vnew",
	})
end)

vim.api.nvim_create_autocmd("FileType", {
	pattern = "nvim-undotree",
	callback = function(ev)
		vim.keymap.set("n", "q", function()
			require("undotree").open()
		end, { buffer = ev.buf, desc = "Close undotree" })
	end,
})

return {}
