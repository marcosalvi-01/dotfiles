return {
	"xzbdmw/clasp.nvim",
	opts = {
		pairs = {
			["{"] = "}",
			["("] = ")",
			["["] = "]",
			["<"] = ">",
			['"'] = '"',
			["'"] = "'",
			["`"] = "`",
		},
		-- If called from insert mode, do not return to normal mode.
		keep_insert_mode = true,
	},
	keys = {
		{
			"<c-l>",
			function()
				require("clasp").wrap("next")
				-- jumping from largest region to smallest region
				-- 	require("clasp").wrap("prev")

				-- If you want to exclude nodes whose end row is not current row
				-- 	require("clasp").wrap("next", function(nodes)
				-- 		local n = {}
				-- 		for _, node in ipairs(nodes) do
				-- 			if node.end_row == vim.api.nvim_win_get_cursor(0)[1] - 1 then
				-- 				table.insert(n, node)
				-- 			end
				-- 		end
				-- 		return n
				-- 	end)
			end,
			mode = { "n", "i" },
			desc = "C[L]asp move next node into brackets",
		},
	},
}
