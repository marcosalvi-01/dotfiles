return {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"lua_ls",
				"gopls",
				"pyright",
				"jq",
				"kulala-fmt",
				"stylua",
				"bashls",
				"prettier",
				"beautysh",
				"stylua",
				"black",
				"xmlformatter",
			},
			automatic_installation = true,
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
}
