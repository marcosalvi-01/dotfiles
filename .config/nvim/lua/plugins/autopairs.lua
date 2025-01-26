return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = true,
	dependencies = {
		-- "hrsh7th/nvim-cmp",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		disable_filetype = { "TelescopePrompt", "spectre_panel" },
		enable_check_bracket_line = true,
		ts_config = {
			lua = { "string" },
			go = { "string" },
			java = false,
			javascript = { "template_string" },
		},
	},
}
