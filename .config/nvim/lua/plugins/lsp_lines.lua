local virtual_lines = true
return {
	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	keys = {
		{
			"<leader>l",
			function()
				if virtual_lines then
					vim.diagnostic.config({ virtual_lines = true })
					vim.diagnostic.config({ virtual_text = false })
					virtual_lines = false
				else
					vim.diagnostic.config({ virtual_lines = false })
					vim.diagnostic.config({ virtual_text = true })
					virtual_lines = true
				end
			end,
			desc = "Toggle lsp_lines",
		},
	},
	config = function()
		vim.diagnostic.config({ virtual_lines = false })
	end,
}

