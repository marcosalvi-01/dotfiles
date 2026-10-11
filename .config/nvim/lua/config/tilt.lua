vim.filetype.add({
	filename = {
		Tiltfile = "tiltfile",
	},
	pattern = {
		["Tiltfile%..+"] = "tiltfile",
	},
})

vim.treesitter.language.register("starlark", "tiltfile")

vim.lsp.config("tiltls", {
	cmd = { "tilt", "lsp", "start" },
	filetypes = { "tiltfile" },
	root_markers = { "Tiltfile", ".git" },
	single_file_support = true,
})

vim.lsp.enable("tiltls")
