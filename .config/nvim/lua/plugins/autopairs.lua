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
		fast_wrap = {
			map = "<c-l>",
			chars = { "{", "[", "(", '"', "'", "`" },
			pattern = [=[[%'%"%>%]%)%}%,]]=],
			end_key = "$",
			before_key = "n",
			after_key = "e",
			cursor_pos_before = false,
			keys = "neia",
			manual_position = false,
			highlight = "Search",
			highlight_grey = "Comment",
		},
	},
}
