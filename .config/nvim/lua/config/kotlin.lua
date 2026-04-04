-- custom config to force enable the lsp inlay hints.
vim.lsp.config("kotlin_lsp", {
	settings = {
		jetbrains = {
			kotlin = {
				hints = {
					parameters = false,
					call = {
						chains = true,
					},
					type = {
						property = true,
						variable = true,
						["function"] = {
							["return"] = true,
							parameter = true,
						},
					},
					lambda = {
						["return"] = true,
						receivers = {
							parameters = true,
						},
					},
					value = {
						ranges = true,
						kotlin = {
							time = true,
						},
					},
				},
			},
		},
	},
})
-- enable the language server
vim.lsp.enable("kotlin_lsp")
