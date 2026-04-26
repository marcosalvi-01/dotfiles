vim.lsp.config("qmlls", {
	cmd = { "/usr/lib/qt6/bin/qmlls" },
	filetypes = { "qml", "qmljs" },
	root_markers = { ".qmlls.ini", ".git", "shell.qml" },
})
vim.lsp.enable("qmlls")
