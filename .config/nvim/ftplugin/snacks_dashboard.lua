vim.schedule(function()
	vim.keymap.set("n", "r", Snacks.dashboard.update, { desc = "Reload snacks dashboard", buffer = true })
end)
