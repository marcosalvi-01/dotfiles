return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		disable_filetype = {
			"TelescopePrompt",
			"snacks_picker_input",
		},
		map_c_w = true,
		check_ts = true,
		enable_check_bracket_line = true,
	},
}
