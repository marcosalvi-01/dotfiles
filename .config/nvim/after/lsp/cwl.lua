local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

-- CWL Language Server
if not configs.cwl_lsp then
	configs.cwl_lsp = {
		default_config = {
			cmd = { "benten-ls" },
			root_dir = lspconfig.util.root_pattern(".git"),
			filetypes = { "cwl" },
		},
	}
end
lspconfig.cwl_lsp.setup({})

return {}
