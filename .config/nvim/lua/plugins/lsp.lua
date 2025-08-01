return {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		cmd = "Mason",
		opts = {
			ensure_installed = {
				-- LSPs
				"lua_ls",
				"gopls",
				"pyright",
				"jdtls",

				-- Tools
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
		opts = {
			automatic_installation = true,
		},
	},
	{
		"mason-org/mason.nvim",
		event = "VeryLazy",
		-- cmd = "Mason",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},
}
