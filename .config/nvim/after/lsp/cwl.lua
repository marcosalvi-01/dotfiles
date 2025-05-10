return {
	cmd = { "benten-ls" },
	root_markers = { ".git" },
	filetypes = { "cwl" },
	on_attach = function(client, bufnr)
		vim.notify("benten-ls attached")
	end,
}
