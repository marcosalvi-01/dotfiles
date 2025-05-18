return {
	"xzbdmw/clasp.nvim",
	opts = {
		pairs = {
			["{"] = "}",
			['"'] = '"',
			["'"] = "'",
			["("] = ")",
			["["] = "]",
			["<"] = ">",
			["`"] = "`",
		},
		-- If called from insert mode, do not return to normal mode.
		keep_insert_mode = true,
		-- consider the following go code:
		--
		-- `var s make()[]int`
		--
		-- if we want to turn it into:
		--
		-- `var s make([]int)`
		--
		-- Directly parse would produce wrong nodes, so clasp always removes the
		-- entire pair (`()` in this case) before parsing, in this case what the
		-- parser would see is `var s make[]int`, but this is still not valid
		-- grammar. For a better parse tree, we can aggressively remove all
		-- alphabetic chars before cursor, so it becomes:
		--
		-- `var s []int`
		--
		-- Now we can correctly wrap the entire `[]int`, because it is identified
		-- as a node. By default we only remove current pair(s) before parsing, in
		-- most cases this is fine, but you can set `remove_pattern = "[a-zA-Z_%-]+$"`
		-- to use a more aggressive approach if you run into problems.
		remove_pattern = nil,
	},
	keys = {
		{
			"<c-l>",
			function()
				require("clasp").wrap("next")
			end,
			mode = { "n", "i" },
		},
		{
			"<c-,>",
			function()
				require("clasp").wrap("prev")
			end,
			mode = { "n", "i" },
		},
	},
}
